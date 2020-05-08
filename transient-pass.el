;;; transient-pass.el --- transient interface for pass
;; Author: ReilySiegel
;; URL: https://github.com/ReilySiegel/transient-pass/
;; Package-Requires: ((password-store "1.6.5") transient seq)

(require 'transient)
(require 'password-store)
(require 'seq)

(define-transient-command transient-pass-dispatch ()
  "List all pass options."
  [["Read"
    ("c" "Copy" password-store-copy)]
   ["Modify"
    ("e" "Edit" password-store-edit)
    ("r" "Rename" password-store-rename)]
   ["Create"
    ("g" "Generate" transient-pass-generate)
    ("i" "Insert" password-store-insert)]])

(define-transient-command transient-pass-generate ()
  :value `(,(format "--length=%i" password-store-password-length))
  [["Arguments"
    ("-f" "Force" "--force")
    ("-l" "Length" "--length="
     transient-read-number-N+)
    ("-s" "No symbols" "--no-symbols")]
   ["Generate"
    ("g" "Generate" transient-pass-generate--dwim)]])

(defun transient-pass-generate-get-length (opts)
  "Return the value of length given a list of OPTS."
  (string-to-number
   (or
    (first (seq-filter (lambda (x) x)
                       (seq-map
                        (lambda (elt)
                          (when (string-match "^--length=\\([0-9]+\\)?$" elt)
                            (match-string 1 elt)))
                        opts)))
    (int-to-string password-store-password-length))))


(define-suffix-command transient-pass-generate--dwim (entry)
  (interactive (list (read-string "Entry Name: ")))
  (password-store--run-generate
   entry
   (transient-pass-generate-get-length (transient-args 'pass-generate))
   (member "--force" (transient-args 'pass-generate))
   (member "--no-symbols" (transient-args 'pass-generate))))

(defun transient-pass (&optional ARG)
  "Entrypoint to transient-pass,
Lauch password-store-copy, or transient-oass-dispatch if prefix
ARG is passed."
  (interactive "P")
  (if ARG
      (call-interactively 'transient-pass-dispatch)
    (password-store-copy)))

(provide 'transient-pass)
;;; transient-pass.el ends here
