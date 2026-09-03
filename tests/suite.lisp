(in-package #:fetch-gist.tests)

(defvar *fixture-directory*
  (merge-pathnames "tests/fixtures/"
                    (asdf:system-source-directory "fetch-gist/tests")))

(defun read-fixture (filename)
  (uiop:read-file-string (merge-pathnames filename *fixture-directory*)))

(defun convert-fixture (name)
  (html->markdown (read-fixture (format nil "~A.html" name))))

(defun lines (&rest strings)
  (format nil "~{~A~^~%~}~%" strings))
