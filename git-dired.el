;; Git dired mode support, part of git-emacs
;;
;; See git-emacs.el for license information

;;TODO when current line have no file.

(require 'git-emacs)

(defun git--dired-view-marked-or-file ()
  (let ((files (git--dired-marked-files)))
    (when (null files)
      (setq files (list (git--dired-get-filename))))
    files))

(defun git--dired-marked-files ()
  (let ((regexp (dired-marker-regexp))
        ret temp)
    (save-excursion
      (goto-char (point-min))
      (while (not (eobp))
        (when (dired-move-to-filename)
          (forward-line 0)
          (when (and (looking-at regexp)
                     (setq temp (git--dired-get-filename))
                     (not (string-match "/\\.\\.?$" temp)))
            (setq ret (cons temp ret))))
        (forward-line 1)))
    (nreverse ret)))

(defun git--dired-get-filename ()
  (dired-get-filename t t))

(provide 'git-dired)
