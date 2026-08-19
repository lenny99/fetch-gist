;;; fetch-gist --- fetch a web page and convert its HTML to Markdown. -*- Mode: Lisp; -*-
(asdf:defsystem "fetch-gist"
  :description "Fetch a web page over HTTP and convert its HTML body to Markdown."
  :version "0.1.0"
  :author "fetch-gist contributors"
  :license "MIT"
  :serial t
  :depends-on ("dexador"
               "babel"
               "cl-ppcre"
               "alexandria"
               "quri"
               "serapeum"
               "iterate")
  :components ((:module "src"
                :serial t
                :components
                  ((:file "package")
                   (:file "html")))))