(in-package #:fetch-gist.tests)

(deftest markdown/documentation-page-converts-to-markdown
  (ok (string= (html->markdown
                (tokenize (read-fixture
                           "pages/example-documentation.html")))
               (read-fixture "pages/example-documentation.md"))))
