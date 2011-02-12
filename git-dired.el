;; Git dired mode support, part of git-emacs
;;
;; See git-emacs.el for license information

(require 'git-emacs)
(require 'dired)

(defun git--dired-view-marked-or-file ()
  (let ((files (git--dired-marked-files)))
    (when (null files)
      (setq files (list (git--dired-single-filename))))
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

(defun git--dired-single-filename ()
  (let ((file (git--dired-get-filename)))
    (unless file
      (error "There is no file"))
    file))

;; mode-line support

(defun git--dired-modeline-string (directory)
  (let* ((default-directory (file-name-as-directory directory))
	 (branch (git--branch-current)))
    (when branch
      (format "Git:%s" branch))))

(defvar git--dired-modeline-in-dired nil)
(make-variable-buffer-local 'git--dired-modeline-in-dired)

(defun git--dired-modeline-install-format ()
  (unless (memq 'git--dired-modeline-in-dired mode-line-format)
    (let* ((cell (assq 'vc-mode mode-line-format))
	   (tail (member cell mode-line-format)))
      (setcdr tail (cons 'git--dired-modeline-in-dired (cdr tail))))))

(defun git--dired-modeline-redraw-format ()
  (setq git--dired-modeline-in-dired (git--dired-modeline-string default-directory))
  (force-mode-line-update))

(defun git-dired-modeline-function ()
  (git--dired-modeline-install-format)
  (git--dired-modeline-redraw-format))

;;TODO when call add-hook
(add-hook 'dired-mode-hook 'git-dired-modeline-function)

(provide 'git-dired)
