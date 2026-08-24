(in-package #:fetch-gist.tests)

(defvar *fixture-directory*
  (merge-pathnames "tests/fixtures/"
                    (asdf:system-source-directory "fetch-gist/tests")))

(defun read-fixture (filename)
  (uiop:read-file-string (merge-pathnames filename *fixture-directory*)))
