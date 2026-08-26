(in-package #:fetch-gist.markdown)

(defparameter *inline-elements*
  '("a" "b" "code" "del" "em" "i" "s" "strong" "kbd"))

(defparameter *block-elements*
  '("blockquote" "div" "h1" "h2" "h3" "h4" "h5" "h6" "li"
    "ol" "p" "pre" "ul"))

(defstruct markdown-state
  stream
  last-character
  newline-count
  pending-space
  suppressed-depth
  pre-depth
  list-types
  blockquote-depth
  link-hrefs)

(defun markdown-emit-character (state character)
  (write-char character (markdown-state-stream state))
  (setf (markdown-state-last-character state) character
        (markdown-state-newline-count state)
        (if (char= character #\Newline)
            (1+ (markdown-state-newline-count state))
            0)))

(defun markdown-emit (state string)
  (loop for character across string do
    (markdown-emit-character state character)))

(defun markdown-ensure-newlines (state count)
  (when (markdown-state-last-character state)
    (loop while (< (markdown-state-newline-count state) count) do
      (markdown-emit-character state #\Newline))))

(defun markdown-start-block (state)
  (setf (markdown-state-pending-space state) nil)
  (markdown-ensure-newlines state 2))

(defun markdown-end-block (state)
  (setf (markdown-state-pending-space state) nil)
  (markdown-ensure-newlines state 2))

(defun markdown-emit-text (state text)
  (setf text (cl-ppcre:regex-replace-all "&quot;" text "\""))
  (if (plusp (markdown-state-pre-depth state))
      (markdown-emit state text)
      (loop for character across text do
        (if (find character '(#\Space #\Tab #\Newline #\Return))
            (setf (markdown-state-pending-space state) t)
            (progn
              (when (and (markdown-state-pending-space state)
                         (markdown-state-last-character state)
                         (not (char= (markdown-state-last-character state)
                                     #\Newline))
                         (not (char= (markdown-state-last-character state)
                                     #\Space)))
                (markdown-emit-character state #\Space))
              (markdown-emit-character state character)
              (setf (markdown-state-pending-space state) nil))))))

(defun markdown-emit-inline-space (state)
  (when (markdown-state-pending-space state)
    (markdown-emit-character state #\Space)
    (setf (markdown-state-pending-space state) nil)))

(defun markdown-heading-p (tag)
  (and (= (length tag) 2)
       (char= (char tag 0) #\h)
       (digit-char-p (char tag 1))))

(defun markdown-suppressed-tag-p (tag)
  (member tag '("head" "style" "script") :test #'string=))

(defun markdown-start-heading (state tag)
  (markdown-start-block state)
  (markdown-emit state
                 (make-string (digit-char-p (char tag 1))
                              :initial-element #\#))
  (markdown-emit state " "))

(defun markdown-start-list (state tag)
  (markdown-start-block state)
  (push (cons tag 0) (markdown-state-list-types state)))

(defun markdown-start-list-item (state)
  (setf (markdown-state-pending-space state) nil)
  (markdown-ensure-newlines state 1)
  (when (markdown-state-list-types state)
    (incf (cdar (markdown-state-list-types state))))
  (if (and (markdown-state-list-types state)
           (string= (caar (markdown-state-list-types state)) "ol"))
      (markdown-emit state
                     (format nil "~D. "
                             (cdar (markdown-state-list-types state))))
      (markdown-emit state "- ")))

(defun markdown-start-inline (state marker)
  (markdown-emit-inline-space state)
  (markdown-emit state marker))

(defun markdown-start-tag (state token)
  (let ((tag (token-tag token)))
    (cond
      ((markdown-suppressed-tag-p tag)
       (incf (markdown-state-suppressed-depth state)))
      ((string= tag "pre")
       (unless (plusp (markdown-state-suppressed-depth state))
         (markdown-start-block state)
         (markdown-emit state "```")
         (markdown-emit-character state #\Newline))
       (incf (markdown-state-pre-depth state)))
      ((plusp (markdown-state-suppressed-depth state)) nil)
      ((markdown-heading-p tag)
       (markdown-start-heading state tag))
      ((member tag '("p" "div") :test #'string=)
       (unless (and (string= tag "p")
                    (plusp (markdown-state-blockquote-depth state)))
         (markdown-start-block state)))
      ((member tag '("strong" "b") :test #'string=)
       (markdown-start-inline state "**"))
      ((member tag '("em" "i") :test #'string=)
       (markdown-start-inline state "*"))
      ((member tag '("del" "s") :test #'string=)
       (markdown-start-inline state "~~"))
      ((member tag '("code" "kbd") :test #'string=)
       (unless (plusp (markdown-state-pre-depth state))
         (markdown-start-inline state "`")))
      ((string= tag "a")
       (markdown-start-inline state "[")
       (push (find-attr token "href") (markdown-state-link-hrefs state)))
      ((string= tag "img")
       (markdown-emit state
                     (format nil "![~A](~A)"
                             (or (find-attr token "alt") "")
                             (or (find-attr token "src") ""))))
      ((string= tag "br")
       (markdown-emit state "  ")
       (markdown-emit-character state #\Newline))
      ((member tag '("ul" "ol") :test #'string=)
       (markdown-start-list state tag))
      ((string= tag "li")
       (markdown-start-list-item state))
      ((string= tag "blockquote")
       (markdown-start-block state)
       (incf (markdown-state-blockquote-depth state))
       (markdown-emit state "> ")))))

(defun markdown-end-list-item (state)
  (setf (markdown-state-pending-space state) nil)
  (markdown-ensure-newlines state 1))

(defun markdown-end-tag (state token)
  (let ((tag (token-tag token)))
    (cond
      ((markdown-suppressed-tag-p tag)
       (when (plusp (markdown-state-suppressed-depth state))
         (decf (markdown-state-suppressed-depth state))))
      ((plusp (markdown-state-suppressed-depth state)) nil)
      ((string= tag "pre")
       (decf (markdown-state-pre-depth state))
       (when (zerop (markdown-state-pre-depth state))
         (markdown-emit-character state #\Newline)
         (markdown-emit state "```")
         (markdown-end-block state)))
      ((string= tag "li")
       (markdown-end-list-item state))
      ((and (string= tag "p")
            (plusp (markdown-state-blockquote-depth state))) nil)
      ((string= tag "blockquote")
       (decf (markdown-state-blockquote-depth state))
       (markdown-end-block state))
      ((member tag '("p" "div") :test #'string=)
       (markdown-end-block state))
      ((markdown-heading-p tag)
       (markdown-end-block state))
      ((member tag '("ul" "ol") :test #'string=)
       (pop (markdown-state-list-types state))
       (markdown-end-block state))
      ((member tag '("strong" "b") :test #'string=)
       (markdown-emit state "**"))
      ((member tag '("em" "i") :test #'string=)
       (markdown-emit state "*"))
      ((member tag '("del" "s") :test #'string=)
       (markdown-emit state "~~"))
      ((member tag '("code" "kbd") :test #'string=)
       (unless (plusp (markdown-state-pre-depth state))
         (markdown-emit state "`")))
      ((string= tag "a")
       (markdown-emit state
                     (format nil "](~A)"
                             (or (pop (markdown-state-link-hrefs state))
                                 "")))))))

(defun markdown-process-token (state token)
  (case (token-kind token)
    (:text (unless (plusp (markdown-state-suppressed-depth state))
             (markdown-emit-text state (token-data token))))
    (:start-tag (markdown-start-tag state token))
    (:end-tag (markdown-end-tag state token))
    (otherwise nil)))

(defun html->markdown (tokens)
  (let ((result
          (with-output-to-string (stream)
            (let ((state (make-markdown-state :stream stream
                                              :newline-count 0
                                              :suppressed-depth 0
                                              :pre-depth 0
                                              :blockquote-depth 0)))
              (dolist (token tokens)
                (markdown-process-token state token))
              (when (and (markdown-state-last-character state)
                         (not (char= (markdown-state-last-character state)
                                     #\Newline)))
                (markdown-emit-character state #\Newline))))))
    (concatenate 'string
                 (string-right-trim '(#\Newline) result)
                 (string #\Newline))))
