(in-package #:fetch-gist.html)

(defstruct token
  kind
  tag
  attrs
  data)

(defun token-kind-p (token kind)
  (eq (token-kind token) kind))

(defun find-attr (token name)
  (cdr (assoc name (token-attrs token) :test #'string-equal)))

(defun html-name-character-p (character)
  (or (alphanumericp character)
      (find character "-_:" :test #'char=)))

(defun text-character-p (character)
  (char/= character #\<))

(defun flatten-characters (items)
  (with-output-to-string (stream)
    (labels ((write-item (item)
               (cond
                 ((characterp item)
                  (write-char item stream))
                 ((consp item)
                  (dolist (child item)
                    (write-item child))))))
       (write-item items))))

(esrap:defrule html-name
    (+ (html-name-character-p character))
  (:lambda (characters)
    (string-downcase (flatten-characters characters))))

(esrap:defrule html-whitespace
    (+ (or #\Space #\Tab #\Newline #\Return)))

(esrap:defrule html-text
    (+ (text-character-p character))
  (:lambda (characters)
    (make-token :kind :text
                :data (flatten-characters characters))))

(esrap:defrule html-attribute-value
    (or (and #\" (* (and (! #\") character)) #\")
        (and #\' (* (and (! #\') character)) #\')
        (+ (and (! (or #\Space #\Tab #\Newline #\Return #\>)) character)))
  (:lambda (parts)
    (flatten-characters (if (characterp (first parts))
                            (second parts)
                            parts))))

(esrap:defrule html-attribute
    (or (and html-name (* html-whitespace) #\= (* html-whitespace)
             html-attribute-value)
        html-name)
  (:lambda (parts)
    (if (stringp parts)
        (list :attribute parts nil)
        (list :attribute (first parts) (fifth parts)))))

(esrap:defrule html-start-tag
    (and #\< html-name (* (or html-whitespace html-attribute)) #\>)
  (:lambda (parts)
    (make-token :kind :start-tag
                :tag (second parts)
                :attrs (mapcar (lambda (item)
                                 (cons (second item) (third item)))
                               (remove-if-not
                                (lambda (item)
                                  (and (consp item)
                                       (eq (first item) :attribute)))
                                 (third parts))))))

(esrap:defrule html-end-tag
    (and "</" html-name (* html-whitespace) #\>)
  (:lambda (parts)
    (make-token :kind :end-tag
                :tag (second parts)
                :attrs nil)))

(esrap:defrule html-doctype
    (and (~ "<!doctype") (* (and (! #\>) character)) #\>)
  (:lambda (parts)
    (make-token :kind :doctype
                :data (string-trim '(#\Space #\Tab #\Newline #\Return)
                                   (flatten-characters (second parts))))))

(esrap:defrule html-token
    (or html-doctype html-end-tag html-start-tag html-text))

(defun token-at (input position)
  (let ((remaining-input (subseq input position)))
    (multiple-value-bind (token remaining success)
        (esrap:parse 'html-token remaining-input :junk-allowed t)
      (values token
              (if (integerp remaining)
                  (+ position remaining)
                  (+ position (- (length remaining-input)
                                 (length remaining))))
              success))))

(defun tokenize (input)
  (loop with position = 0
        with tokens = nil
        while (< position (length input))
        do (multiple-value-bind (token new-position success)
               (token-at input position)
             (if (and success (> new-position position))
                 (progn
                   (push token tokens)
                   (setf position new-position))
                 ;; A malformed '<' is text rather than a fatal parse error.
                 (progn
                   (push (make-token :kind :text
                                     :data (string (char input position)))
                         tokens)
                   (incf position))))
        finally (return (nreverse tokens))))
