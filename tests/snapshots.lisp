(in-package #:fetch-gist.tests)

(defvar *snapshot-directory*
  (merge-pathnames "tests/"
                   (asdf:system-source-directory "fetch-gist/tests")))

(defun snapshot-path (name type)
  (merge-pathnames (make-pathname :type type
                                  :defaults (pathname name))
                   *snapshot-directory*))

(defun write-snapshot (pathname contents)
  (ensure-directories-exist pathname)
  (with-open-file (stream pathname
                          :direction :output
                          :if-exists :error
                          :if-does-not-exist :create)
    (write-string contents stream)))

(defun snapshot (name contents)
  (let ((pathname (snapshot-path name "snap")))
    (if (probe-file pathname)
        (string= contents (uiop:read-file-string pathname))
        (progn
          (unless (probe-file (snapshot-path name "snap.new"))
            (write-snapshot (snapshot-path name "snap.new") contents))
          nil))))

(defun format-string (string)
  (with-output-to-string (stream)
    (write-char #\" stream)
    (loop for character across string do
      (case character
        (#\\ (write-string "\\\\" stream))
        (#\" (write-string "\\\"" stream))
        (#\Newline (write-string "\\n" stream))
        (#\Return (write-string "\\r" stream))
        (#\Tab (write-string "\\t" stream))
        (otherwise (write-char character stream))))
    (write-char #\" stream)))

(defun format-value (value)
  (if (stringp value)
      (format-string value)
      (format nil "~S" value)))

(defun format-token (token)
  (format nil "(:kind ~A :tag ~A :attrs ~A :data ~A)"
          (format-value (token-kind token))
          (format-value (token-tag token))
          (format-value (token-attrs token))
          (format-value (token-data token))))

(defun snapshot-tokens (name tokens)
  (snapshot name
            (format nil "~{~A~^~%~}"
                    (mapcar #'format-token tokens))))

(defun cleanup-snapshots ()
  (labels ((cleanup-directory (directory)
             (dolist (pathname (uiop:directory-files directory))
               (let ((namestring (namestring pathname)))
                 (when (and (uiop:string-suffix-p namestring ".snap.new")
                            (probe-file (pathname
                                         (subseq namestring
                                                 0
                                                 (- (length namestring) 4)))))
                   (delete-file pathname))))
             (dolist (subdirectory (uiop:subdirectories directory))
               (cleanup-directory subdirectory))))
    (when (probe-file *snapshot-directory*)
      (cleanup-directory *snapshot-directory*))))
