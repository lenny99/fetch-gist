(in-package #:fetch-gist.tests)

(deftest tokenize-html/empty-body-produces-no-tokens
  (ok (snapshot-tokens "fixtures/empty"
                       (tokenize (read-fixture "empty.html")))))

(deftest tokenize-html/plain-text-produces-text-token
  (ok (snapshot-tokens "fixtures/01-plain-text"
                       (tokenize (read-fixture "01-plain-text.html")))))

(deftest tokenize-html/element-produces-start-text-and-end-tokens
  (ok (snapshot-tokens "fixtures/02-single-element"
                       (tokenize (read-fixture "02-single-element.html")))))
