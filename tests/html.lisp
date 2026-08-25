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

(deftest tokenize-html/void-elements-produce-start-tokens-without-end-tokens
  (ok (snapshot-tokens "fixtures/03-void-elements"
                       (tokenize (read-fixture "03-void-elements.html")))))

(deftest tokenize-html/attributes-produce-an-element-token
  (ok (snapshot-tokens "fixtures/04-attributes"
                       (tokenize (read-fixture "04-attributes.html")))))

(deftest tokenize-html/whitespace-and-case-are-normalized
  (ok (snapshot-tokens "fixtures/05-whitespace-case"
                       (tokenize (read-fixture "05-whitespace-case.html")))))

(deftest tokenize-html/nested-elements-produce-nested-token-sequence
  (ok (snapshot-tokens "fixtures/06-nested"
                       (tokenize (read-fixture "06-nested.html")))))

(deftest tokenize-html/special-elements-produce-special-token-sequence
  (ok (snapshot-tokens "fixtures/07-special"
                       (tokenize (read-fixture "07-special.html")))))

(deftest tokenize-html/entities-remain-in-text-token
  (ok (snapshot-tokens "fixtures/08-entities"
                       (tokenize (read-fixture "08-entities.html")))))

(deftest tokenize-html/mixed-content-produces-ordered-token-sequence
  (ok (snapshot-tokens "fixtures/09-mixed"
                       (tokenize (read-fixture "09-mixed.html")))))

(deftest tokenize-html/malformed-input-recovers-as-text
  (ok (snapshot-tokens "fixtures/10-malformed"
                       (tokenize (read-fixture "10-malformed.html")))))

(deftest tokenize-html/real-world-document-produces-ordered-token-sequence
  (ok (snapshot-tokens "fixtures/11-real-world"
                       (tokenize (read-fixture "11-real-world.html")))))
