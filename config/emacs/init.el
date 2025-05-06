;; ====== Package Setup =====
;; Melpa stuff
(require 'package)
;; Bullshit TLS bug workaround
; (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")
(setq package-check-signature nil)
(add-to-list 'package-archives '("melpa" .
				 "https://melpa.org/packages/"
				 ))
(add-to-list 'package-archives '("gnu" .
				 "https://elpa.gnu.org/packages/"
				 ))
(package-initialize)

;; Ensure use-package is available
(when (not (package-installed-p 'use-package))
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
;; Move Custom file away from here
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(unless (file-exists-p custom-file) (write-region "" nil custom-file))
(load custom-file)
;; Shell PATH sanitization
(use-package exec-path-from-shell
  :ensure t
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))
;; Use dash library
(use-package dash
  :ensure t
  :config
  (dash-enable-font-lock))

;; ===== Emacs Settings =====
;; Command key map for Mac
(setq mac-command-modifier 'control)
;; Start maximized
(add-to-list 'default-frame-alist '(fullscreen . maximized))
;; Zenburn Theme
(use-package zenburn-theme
  :ensure t
  :config
  ;; Zenburn's default highlight color is near impossible to see.
  (setq zenburn-override-colors-alist
  '(("zenburn-bg-05" . "dodger blue")))
  (load-theme 'zenburn t))
;; Backup Themes
(use-package color-theme-sanityinc-tomorrow
  :ensure t)
(use-package solarized-theme
  :ensure t
  :custom
  (solarized-use-less-bold t)
  )
(use-package ample-theme
  :ensure t
  :defer t)
;; Font settings
(defun font-candidate (&rest fonts)
  (-first (lambda (f) (find-font (font-spec :name f))) fonts))
(setq preferred-font (font-candidate "Monaco-15"))
(if (bound-and-true-p preferred-font) (set-frame-font preferred-font))
;; Don't ding me, only flash modeline
(defun bell-mode-line ()
  (invert-face 'mode-line)
  (run-with-timer 0.1 nil #'invert-face 'mode-line))
(setq visible-bell nil
      ring-bell-function 'bell-mode-line)
;; Quick process kill
(setq confirm-kill-processes t)
;; Say no to scrollbars
(scroll-bar-mode -1)
;; Ignore generated files
(setq completion-ignored-extensions
  (append completion-ignored-extensions
    '(".agdai" ".hi" ".exe" ".git" "MAlonzo/")))

;; ======= Package Settings =====
;; Window Resize
(use-package golden-ratio
  :ensure t
  :after evil
  :custom
  (golden-ratio-auto-scale t)
  (golden-ratio-extra-commands
   '(evil-window-next
     evil-window-prev))
  :config
  (golden-ratio-mode 1))
;; General
(use-package general :ensure t)

;; Evil
(use-package evil
  :ensure t
  :custom
  (evil-want-abbrev-expand-on-insert-exit nil "Having this on fucks with Coq proofs")
  (evil-want-keybinding nil "Required for evil-collection")
  (evil-want-C-u-scroll t "Use <C-u> to scroll up")
  (evil-vsplit-window-below t "Split windows to the bottom")
  (evil-vsplit-window-right t "Split vwindows to the right")
  (evil-undo-system 'undo-redo)
  :config
  (evil-mode 1)
  (general-evil-setup))

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init)
  (general-nmap
    :prefix "SPC"
    "v" 'evil-window-vnew)
  (general-nmap
    ;; Quickly insert blank lines
    "C-k" #'(lambda () (interactive)
	      (evil-save-column
		(evil-insert-newline-above)
		(evil-line 2)))
    "C-j" #'(lambda () (interactive)
	      (evil-save-column
		(evil-insert-newline-below)
		(evil-previous-line)))
    ;; "Y" same as "y$"
    "Y" "y$"
    ;; Map numbers
    "1" "9 9 9 9 9 9 9 9"
    "2" "@"
    "3" "#"
    "4" "$"
    "5" "%"
    "6" "^"
    "7" "&"
    "8" "*"
    )
  ;; TODO: how do I map ex commands?
  (general-define-key
   :keymaps 'evil-ex-map
   "C-k" "C-p"
   "C-j" "C-n")
  ;; Same as Vim :put
  (defun vim-put () (interactive)
	 (evil-save-column
	   (let
	       ((curline (line-number-at-pos)))
	     (evil-insert-newline-below)
	     (evil-paste-from-register ?\")
	     (goto-line curline)
	     )))
  (evil-ex-define-cmd "pu" 'vim-put)
  (evil-ex-define-cmd "put" 'vim-put)
  ;; Lisp
  (general-nmap
    :prefix "SPC"
    :keymaps 'emacs-lisp-mode-map
    "m" '(lambda ()
	   (interactive)
	   (eval-buffer)))
  (general-vmap
    :prefix "SPC"
    :keymaps 'emacs-lisp-mode-map
    "m" #'(lambda ()
	    (interactive)
	    (eval-region evil-visual-beginning evil-visual-end)
	    (evil-force-normal-state))))


(use-package evil-surround
  :ensure t
  :config
  (global-evil-surround-mode))

(use-package evil-commentary
  :ensure t
  :config
  (evil-commentary-mode))

;; Ivy, Swiper, Counsel
(use-package flx :ensure t)
(use-package counsel
  :ensure t
  :after (general flx)
  :custom
  (ivy-use-virtual-buffers t)
  (ivy-count-format "(%d/%d) ")
  (ivy-re-builders-alist
   '((counsel-ag . ivy--regex-plus)
     (t . ivy--regex-fuzzy))
   "Use fuzzy search for most cases, definitely not for ag")
  (counsel-find-file-ignore-regexp
   (regexp-opt completion-ignored-extensions))
  :config
  (ivy-mode 1)
  (general-define-key
   :keymaps 'ivy-mode-map
   "C-j" 'ivy-next-line
   "C-k" 'ivy-previous-line
   "C-w" 'ivy-backward-kill-word
   "C-u" 'ivy-kill-line
   ;; This is pretty counterintuitive, but apparently this is
   ;; the correct behavior
   "C-u" 'ivy-scroll-down-command
   "C-d" 'ivy-scroll-up-command
   )
  (ivy-configure 'counsel-M-x
    :initial-input "")
  (general-nmap
    :keymaps 'ivy-mode-map
    :prefix "SPC"
    "SPC" 'counsel-switch-buffer)
  (general-nmap
    :prefix "SPC"
    "x" 'counsel-M-x
    "s" 'counsel-describe-variable
    )
  )
(use-package ivy-hydra :ensure t :after counsel)

;; Projectile
(use-package projectile
  :ensure t
  :after (counsel general evil)
  :config
  (projectile-mode 1))

(use-package counsel-projectile
  :ensure t
  :after projectile
  :config
  (general-nmap
    :keymaps 'projectile-mode-map
    :prefix "SPC"
    "p" 'counsel-projectile-switch-project
    "f" 'counsel-projectile-find-file
    )
  (defun grep (&optional options)
    "My renamed version of vimgrep using projectile instead"
    (interactive) (counsel-projectile-ag options))
  )

;; Restart Emacs
(use-package restart-emacs
  :ensure t)

;; Rainbow delimiters
(use-package rainbow-delimiters
  :ensure t
  :config
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

;; Company
(use-package company
  :ensure t
  :config
  (add-hook 'after-init-hook 'global-company-mode))

;: Which Key
(use-package which-key
  :ensure t
  :config (which-key-mode))

;; Shell Pop
(use-package shell-pop
  :ensure t
  :after evil
  :custom
  (shell-pop-shell-type
   '("ansi-term" "*ansi-term*" (lambda () (ansi-term shell-pop-term-shell))))
  (shell-pop-term-shell "/bin/bash")
  (shell-pop-window-size 30)
  (shell-pop-full-span t)
  (shell-pop-window-position "bottom")
  :config
  (evil-ex-define-cmd "sh" 'shell-pop))

;; Popwin
(use-package popwin
  :ensure t
  :after general
  :config
  (popwin-mode)
  (push
   '(compilation-mode :noselect t :dedicated nil :stick t)
   popwin:special-display-config)
  (push
   '("*Agda information*" :noselect t :dedicated nil :stick t :position bottom :height 5)
   popwin:special-display-config)
  (push
   '(help-mode :noselect t :dedicated nil :position top :height 8)
   popwin:special-display-config)
  (general-nmap
    :prefix "SPC"
    :keymaps '(compilation-mode-map)
    "q" #'(lambda () (interactive)
	    (if popwin:popup-window
		(popwin:close-popup-window)
	      (popwin:popup-last-buffer)))))

;; Markdown Mode
(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
	 ("\\.md\\'" . markdown-mode)
	 ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown")
  :config
  (general-nmap
   :prefix "SPC"
   :keymaps '(markdown-mode-map)
   "m" 'markdown-preview)
  )

;; xkcd lmao
(use-package xkcd
  :ensure t
  :config
  (evil-set-initial-state 'xkcd-mode 'normal)
  (general-nmap
    :keymaps 'xkcd-mode-map
    "h" 'xkcd-prev
    "l" 'xkcd-next
    "r" 'xkcd-rand
    "q" 'xkcd-kill-buffer
    "t" 'xkcd-alt-text
    )
  )

;; Latex
;; AucTex code is some insane clusterfuck, so I did what I could, bleh
(use-package tex
  :ensure auctex
  :custom
  (TeX-PDF-mode t)
  (TeX-clean-confirm nil)
  :config
  (general-nmap
    :keymaps 'TeX-mode-map
    :prefix "SPC"
    "m" 'TeX-command-run-all
    "n" 'TeX-clean
    ))

;; SML
(use-package sml-mode
  :ensure t)

;; Proof General
(use-package proof-general
  :ensure t
  :custom
  (proof-splash-time 2)
  (coq-load-path-include-current t)
  :config
  (general-nmap
    :keymaps 'proof-mode-map
    :prefix "SPC"
    "j" 'proof-assert-next-command-interactive
    "k" 'proof-undo-last-successful-command
    "l" 'proof-goto-point
    "n" 'proof-process-buffer
    "q" 'coq-query
    "x" 'coq-Print
    "c" 'coq-Check
    "z" 'coq-LocateConstant
    )
  )

;; Company Coq
(use-package company-coq
  :ensure t
  :after proof-general
  :config
  (add-hook 'coq-mode-hook #'company-coq-mode)
  (general-nmap
    :keymaps 'proof-mode-map
    "gd" 'company-coq-jump-to-definition
    )
  )

;; Dammit Twelf doesn't have a package
(if (eq system-type 'darwin)
    (setq twelf-root "/Users/haoxuany/tools/twelf/")
  (if (eq system-type 'gnu/linux)
      (setq twelf-root "~/tools/twelf/")
    (setq twelf-root "")))
(if (file-directory-p twelf-root)
    (load (concat twelf-root "emacs/twelf-init.el")))
(general-nmap
  :keymaps 'twelf-mode-map
  :prefix "SPC"
  "m" 'twelf-save-check-config
  "n" 'twelf-save-check-file
  "l" 'twelf-check-declaration
  "z" 'twelf-font-fontify-buffer
  "s" 'twelf-server-display
)
(add-hook
 'twelf-mode-hook
 (lambda nil (progn
	       (if (null (get-buffer-process (twelf-get-server-buffer t)))
		   (twelf-server twelf-server-program))
	       (load-theme 'ample-flat t t)
	       (enable-theme 'ample-flat)
	       )))
(add-hook
 'twelf-mode-hook
 (lambda nil
   (progn
     (face-remap-add-relative
      'twelf-font-evar-face
      '(:foreground "DeepSkyBlue"))
     (face-remap-add-relative
      'twelf-font-fvar-face
      '(:foreground "DeepSkyBlue"))
     (face-remap-add-relative
      'twelf-font-decl-face
      '(:foreground "maroon1"))
     (face-remap-add-relative
      'twelf-font-const-face
      '(:foreground "gold1"))
     (face-remap-add-relative
      'twelf-font-comment-face
      '(:foreground "grey60"))
     )))

;; Agda mode
(eval-and-compile
  (defun agda-load-path ()
    (let ((coding-system-for-read 'utf-8))
      (shell-command-to-string "agda-mode locate"))
    ))

(use-package agda2
  :after evil
  :ensure nil
  :if (file-readable-p (agda-load-path))
  :init (load-file (agda-load-path))
  :load-path (lambda () (list (agda-load-path)))
  :custom
  (agda2-backend "GHC" "Use GHC backend for agda compilation")
  :config
  (add-to-list 'auto-mode-alist '("\\.lagda.md\\'" . agda2-mode))
  (general-nmap
    :prefix "SPC"
    :keymaps 'agda2-mode-map
    "m" 'agda2-compile
    "c" 'describe-char
    "l" 'agda2-load
    "s" 'agda2-make-case
    "g" 'agda2-give
    "t" 'agda2-goal-and-context
    "r" 'agda2-refine
    "d" 'agda2-goto-definition-keyboard
    "n" #'(lambda ()
	    (interactive)
	    (agda2-goal-and-context "C-u C-u"))
    "q" #'(lambda () (interactive)
	    (if popwin:popup-window
		(popwin:close-popup-window)
	      (popwin:popup-last-buffer)))
  )
  (general-nmap
    :keymaps 'agda2-mode-map
    "gd" 'agda2-goto-definition-keyboard
  )
)

;; OCaml
(use-package tuareg
  :ensure t
)

(use-package dune
  :ensure t)

(use-package eglot
  :ensure t
  :config
  (add-hook 'tuareg-mode-hook 'eglot-ensure)
)
