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

(defpackage #:fetch-gist.markdown
  (:use #:cl #:alexandria #:serapeum)
  (:shadowing-import-from #:iterate
                          #:in #:until #:count)
  (:import-from #:iterate
                #:iter #:for #:collect)
  (:import-from #:plump
                #:parse
                #:node-p
                #:nesting-node-p
                #:text-node-p
                #:element-p
                #:children
                #:text
                #:tag-name
                #:attributes)
  (:export #:html->markdown
           #:*inline-elements*
           #:*block-elements*))

(defpackage #:fetch-gist.cli
  (:use #:cl #:fetch-gist #:fetch-gist.markdown)
  (:export #:main))
