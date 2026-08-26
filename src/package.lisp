;;;; package.lisp --- package definition for fetch-gist. -*- Mode: Lisp; -*-
(defpackage #:fetch-gist
  (:use #:cl #:alexandria #:serapeum)
  (:shadowing-import-from #:iterate
                          #:in #:until #:count)
  (:import-from #:iterate
                #:iter #:for #:collect)
  (:export #:fetch-url
           #:fetch-url-to-string
           #:html-content-type-p
           #:markdown-content-type-p
           #:markdown-from-string
           #:markdown-from-file
           #:markdown-from-url
           #:*fetch-timeout*))

(defpackage #:fetch-gist.html
  (:use #:cl #:alexandria #:serapeum #:esrap)
  (:shadowing-import-from #:iterate
                          #:in #:until #:count)
  (:import-from #:iterate
                #:iter #:for #:collect)
  (:export #:make-token
           #:token-kind
           #:token-tag
           #:token-attrs
           #:token-data
           #:tokenize
           #:token-kind-p
           #:find-attr))

(defpackage #:fetch-gist.markdown
  (:use #:cl #:fetch-gist.html #:alexandria #:serapeum)
  (:shadowing-import-from #:iterate
                          #:in #:until #:count)
  (:import-from #:iterate
                #:iter #:for #:collect)
  (:export #:html->markdown
           #:*inline-elements*
           #:*block-elements*))

(defpackage #:fetch-gist.cli
  (:use #:cl #:fetch-gist #:fetch-gist.markdown)
  (:export #:main))
