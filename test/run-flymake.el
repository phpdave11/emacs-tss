(require 'tss)
(require 'ert-expectations)
(require 'tenv)

(expectations
  (desc "run-flymake cmdstr")
  (expect t
    (tss--log-enable-logging)
    (tss--log-set-level 'trace)
    (tss--log-clear-log)
    (stub tss--active-p => t)
    (stub tss--exist-process => t)
    (stub tss--sync-server => t)
    (stub tss--get-process => nil)
    (stub process-send-string => nil)
    (tss-run-flymake)
    (with-current-buffer (get-buffer " *log4e-tss*")
      (goto-char (point-max))
      (when (search-backward "cmdstr" nil t)
        (string= (buffer-substring-no-properties (point) (point-at-eol))
                 (concat "cmdstr[showErrors] waitsec[2]")))))
  (desc "run-flymake do flymake when save")
  (expect '("Found error file[/tmp/fuga] line[50] col[59] ... fugaga" "Found error file[/tmp/hoge] line[16] col[57] ... hogege")
    (stub tss--active-p => t)
    (stub tss--exist-process => t)
    (stub tss--sync-server => t)
    (stub tss--get-server-response => '[((text . "hogege") (end (col . 67) (line . 16)) (start (col . 57) (line . 16)) (file . "/tmp/hoge")) ((text . "fugaga") (end (col . 69) (line . 50)) (start (col . 59) (line . 50)) (file . "/tmp/fuga"))])
    (let* ((tfile (tenv-get-tmp-file "tss" "flymake.ts" nil t)))
      (with-current-buffer (find-file-noselect tfile)
        (erase-buffer)
        (insert "var s1;\n")
        (tss-setup-current-buffer)
        (save-buffer))
      (with-current-buffer (get-buffer " *log4e-tss*")
        (goto-char (point-max))
        (loop while (search-backward "Found error" nil t)
              collect (buffer-substring-no-properties (point) (point-at-eol))))))
  )

