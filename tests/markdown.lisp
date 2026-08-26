(in-package #:fetch-gist.tests)

(deftest markdown/documentation-page-converts-to-markdown
  (ok (string= (html->markdown
                (tokenize (read-fixture
                           "pages/example-documentation.html")))
                (read-fixture "pages/example-documentation.md"))))

(deftest markdown-from-string/converts-html
  (ok (string= (markdown-from-string "<p>Hello <strong>world</strong>.</p>")
               (concatenate 'string "Hello **world**." (string #\Newline)))))

(deftest markdown-from-file/converts-html
  (ok (string= (markdown-from-file
                (merge-pathnames "pages/example-documentation.html"
                                 *fixture-directory*))
               (read-fixture "pages/example-documentation.md"))))
