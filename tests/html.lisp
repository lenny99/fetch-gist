(in-package #:fetch-gist.tests)

(deftest tokenize-html/empty-body-produces-no-tokens
  (let ((html (read-fixture "empty.html")))
    (ok (notany (lambda (token)
                  (and (token-kind-p token :text)
                       (plusp (length (string-trim '(#\Space #\Tab #\Newline #\Return)
                                                   (token-data token))))))
                (tokenize html)))))

(deftest tokenize-html/plain-text-produces-text-token
  (let ((tokens (tokenize (read-fixture "01-plain-text.html"))))
    (ok (= 1 (length tokens)))
    (ok (token-kind-p (first tokens) :text))
    (ok (string= (format nil "hello world~%")
                 (token-data (first tokens))))))

(deftest tokenize-html/element-produces-start-text-and-end-tokens
  (let ((tokens (tokenize (read-fixture "02-single-element.html"))))
    (ok (= 4 (length tokens)))
    (ok (token-kind-p (first tokens) :start-tag))
    (ok (string= "p" (token-tag (first tokens))))
    (ok (token-kind-p (second tokens) :text))
    (ok (string= "hello" (token-data (second tokens))))
    (ok (token-kind-p (third tokens) :end-tag))
    (ok (string= "p" (token-tag (third tokens))))
    (ok (token-kind-p (fourth tokens) :text))
    (ok (string= (format nil "~%") (token-data (fourth tokens))))))
