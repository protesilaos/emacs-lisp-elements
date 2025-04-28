(use-modules
 (guix packages)
 (guix build-system copy)
 (guix build utils)
 (guix gexp)
 ;; (guix git)
 (guix git-download)
 (guix licenses)
 (gnu packages emacs)
 (gnu packages texinfo)
 ;; (gnu packages guile)
 ;; (gnu packages guile-xyz)
 ;; (gnu packages tls)
 (ice-9 popen)
 (ice-9 textual-ports)
 ;; (srfi srfi-1)
 )

(define %source-dir
  (dirname (current-filename)))

(define %git-commit
  (with-directory-excursion %source-dir
    (get-line (open-input-pipe "git rev-parse HEAD"))))

(define-public emacs-lisp-elements
  (package
    (name "emacs-lisp-elements")
    (version (git-version "0.1" "HEAD" %git-commit))
    (source (local-file %source-dir
                        #:recursive? #t
                        #:select? (git-predicate %source-dir)))
    (build-system copy-build-system)
    (arguments
     (list
      #:install-plan #~'(("elispelem.info" "share/info/"))
      #:phases #~(modify-phases %standard-phases
                   (add-after 'patch-source-shebangs 'compile-the-files
                     (lambda _
                       (import (ice-9 ftw))
                       (system* "emacs"
                                "--batch"
                                "--eval"
                                "(progn
      (find-file \"elispelem.org\")
      (org-texinfo-export-to-info))"))))))
    (native-inputs (list emacs texinfo))
    (home-page "https://github.com/protesilaos/emacs-lisp-elements/")
    (synopsis "Emacs Lisp Elements")
    (description "This book, written by Protesilaos Stavrou, also known as “Prot”, provides a big picture view of the Emacs Lisp programming language.")
    (license fdl1.3+)))

emacs-lisp-elements
