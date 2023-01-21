;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

(defun start-go-term ()
  (interactive)
  (shell "go-term")
  (switch-to-buffer (other-buffer (current-buffer) t))
  )

;; run go file
(defun run-go-file ()
  (interactive)
  (setq cur-file-name (buffer-name (window-buffer (minibuffer-selected-window))))
  (switch-to-buffer "go-term")
  (comint-clear-buffer)
  (insert "go run ")
  (insert (format "%s" cur-file-name))
  (comint-send-input)
  ;; (switch-to-buffer (other-buffer (current-buffer) t))
)

;; run go test file
(defun run-go-test-file ()
  (interactive)
  (setq cur-file-name (buffer-name (window-buffer (minibuffer-selected-window))))
  (switch-to-buffer "go-term")
  (comint-clear-buffer)
  (insert "go test ")
  (insert (format "%s" cur-file-name))
  (comint-send-input)
  ;; (switch-to-buffer (other-buffer (current-buffer) t))
)

;; run go modules
(defun run-go-modules ()
  (interactive)
  (setq cur-file-name (buffer-name (window-buffer (minibuffer-selected-window))))
  (switch-to-buffer "go-term")
  (comint-clear-buffer)
  (insert "go run .")
  ;; (insert (format "%s" cur-file-name))
  (comint-send-input)
  ;; (switch-to-buffer (other-buffer (current-buffer) t))
)

;; SPC keybinds
(map! :leader
     (:prefix-map ("r" . "run")
        :desc "run go file"                                                      "g" #'run-go-file
        :desc "run go test"                                                      "t" #'run-go-test-file
        :desc "run go modules"                                                   "m" #'run-go-modules
        ))

;; remap ctrl + shift + e to select treemacs window
;; (define-key global-map (kbd "C-E") 'treemacs-select-window)
;; (define-key global-map (kbd "C-S-E") 'treemacs-select-window)
(define-key global-map (kbd "C-S-E") 'neotree-show)

;; remap ctrl + / to comment line
(define-key global-map (kbd "C-/") 'comment-line)

;; real auto save mode
 (add-hook 'prog-mode-hook 'real-auto-save-mode)
 (setq real-auto-save-interval 1) ;; in seconds

;; Switch other buffer
(map! :leader "ESC" #'evil-switch-to-windows-last-buffer)

;; Emacs GTD
;; https://github.com/rougier/emacs-gtd
(setq org-directory "~/Dropbox/notes")
(after! org
  (setq org-agenda-files (list "inbox.org" "projects.org" "agenda.org" "notes.org"))
  ;; (setq org-agenda-files (list "projects.org"))
  ;; (setq org-agenda-files (list "notes.org"))
  )

(after! org
  (setq org-capture-templates
       `(("i" "Inbox" entry  (file "inbox.org")
        ,(concat "* TODO %?\n"
                 "/Entered on/ %U"))
        ("m" "Meeting" entry  (file+headline "agenda.org" "Future")
         ,(concat "* %? :meeting:\n"
                  "<%<%Y-%m-%d %a %H:00>>"))
        ("n" "Note" entry  (file "notes.org")
         ,(concat "* Note (%a)\n"
                  "/Entered on/ %U\n" "\n" "%?"))
        ("@" "Inbox [mu4e]" entry (file "inbox.org")
        ,(concat "* TODO Reply to %?\n"
                 "/Entered on/ %U"))
         ))
  )


(defun org-capture-inbox ()
     (interactive)
     (call-interactively 'org-store-link)
     (org-capture nil "i"))

(define-key global-map (kbd "C-c a") 'org-agenda)
(define-key global-map (kbd "C-c c") 'org-capture)
(define-key global-map (kbd "C-c i") 'org-capture-inbox)

;; (setq org-agenda-hide-tags-regexp ".")

;; (setq org-agenda-prefix-format
;;       '((agenda . " %i %-12:c%?-12t% s")
;;         (todo   . " ")
;;         (tags   . " %i %-12:c")
;;         (search . " %i %-12:c")))

;; Refile
(after! org
  (setq org-refile-targets
      '(("projects.org" :regexp . "\\(?:\\(?:Note\\|Task\\)s\\)")))
  )
(setq org-refile-use-outline-path 'file)
(setq org-outline-path-complete-in-steps nil)

;; TODO
(after! org
  (setq org-todo-keywords
      '((sequence "TODO(t)" "NEXT(n)" "HOLD(h)" "BUG(b)" "|" "DONE(d)" "KILL(k)")))
  )

(defun log-todo-next-creation-date (&rest ignore)
  "Log NEXT creation time in the property drawer under the key 'ACTIVATED'"
  (when (and (string= (org-get-todo-state) "NEXT")
             (not (org-entry-get nil "ACTIVATED")))
    (org-entry-put nil "ACTIVATED" (format-time-string "[%Y-%m-%d]"))))
(add-hook 'org-after-todo-state-change-hook #'log-todo-next-creation-date)

;; custom agenda
(setq org-agenda-custom-commands
      '(("g" "Get Things Done (GTD)"
         ((agenda ""
                  ((org-agenda-skip-function
                    '(org-agenda-skip-entry-if 'deadline))
                   (org-deadline-warning-days 0)
                   (org-agenda-start-day "0d")
                   (org-agenda-span 'day)
                   ))
          (todo "NEXT"
                ((org-agenda-skip-function
                  '(org-agenda-skip-entry-if 'deadline))
                 (org-agenda-prefix-format "  %i %-12:c [%e] ")
                 (org-agenda-overriding-header "\nTasks\n")))
          (agenda nil
                  ((org-agenda-entry-types '(:deadline))
                   (org-agenda-format-date "")
                   (org-deadline-warning-days 7)
                   (org-agenda-skip-function
                    '(org-agenda-skip-entry-if 'notregexp "\\* NEXT"))
                   (org-agenda-overriding-header "\nDeadlines")))
          (tags-todo "inbox"
                     ((org-agenda-prefix-format "  %?-12t% s")
                      (org-agenda-overriding-header "\nInbox\n")))
          (tags "CLOSED>=\"<today>\""
                ((org-agenda-overriding-header "\nCompleted today\n")))))))

(setq org-log-done 'time)

;;;; run custom org-agenda at startup
(org-agenda nil "g")

;; BUG error org-matcher-time defun in org-encode-time
;; Updating emacs and doom emacs fix this bug

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "John Doe"
      user-mail-address "john@doe.com")

;; deft
(setq deft-extensions '("txt" "tex" "org"))
(setq deft-directory "~/Dropbox/notes")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;

(setq doom-font "Fira Code-13")
;; (setq doom-font (font-spec :family "Fira Code" :size 15 :weight 'semi-light)
     ;; doom-variable-pitch-font (font-spec :family "Fira Sans" :size 16))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
 ;; (setq doom-theme 'doom-monokai-pro)
(setq doom-theme 'doom-molokai)
;;(setq doom-theme 'doom-flatwhite)
;; (setq doom-theme 'doom-city-lights)
;; (setq doom-theme 'doom-one)
;;(setq doom-theme 'doom-gruvbox-light)
;; (setq doom-theme 'doom-nord)
;; (setq doom-theme 'doom-material)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
;; (setq display-line-numbers-type t)
(setq display-line-numbers-type 'visual)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!

;;;;;;;; my settings ;;;;;;;;;;;;;;;
;; Orgzly
(setq org-directory "~/Dropbox/notes")

;; emacs-easy-hugo
(setq easy-hugo-basedir "~/Projects/moanrisy.github.io/")
(setq easy-hugo-postdir "content/blog")
(setq easy-hugo-url "https://moanrisy.github.io")
(setq easy-hugo-default-ext ".org")

;; Hook for clock-in
(defun write-clock-in-title-hook()
"Write clock in title into a file"
(message (symbol-value 'org-clock-heading))
(message "clocked time %d." (org-clock-get-clocked-time))
(append-to-file (number-to-string (org-clock-get-clocked-time)) nil "/tmp/clock-in-title")
(append-to-file "/" nil "/tmp/clock-in-title")

(when (symbol-value 'org-clock-effort)
(append-to-file (symbol-value 'org-clock-effort) nil "/tmp/clock-in-title"))

(append-to-file " " nil "/tmp/clock-in-title")
(append-to-file (symbol-value 'org-clock-heading) nil "/tmp/clock-in-title")
(append-to-file "\n" nil "/tmp/clock-in-title")
)

(add-hook 'org-clock-in-hook 'write-clock-in-title-hook)
(run-at-time nil 60 #'write-clock-in-title-hook)
;; (run-at-time nil 5 #'write-clock-in-title-hook)

;; BUG clock-in-fyne can't read after file cleaned
;; TODO update clock-in-fyne app
;; (defun clear-clock-in-title-file()
;;   (write-region "" "" "~/clock-in-title")
;;   )
;; (add-hook 'after-init-hook 'clear-clock-in-title-file)

;; BUG: clock-out called after clock-in, it should clock-out first then clock-in
;; Hook for clock-out
;; (defun write-clock-out-title-hook()
;; "Write clock in title into a file"
;; (message "Let's choose another task")
;; (append-to-file "Let's choose another task" nil "~/clock-in-title")
;; (append-to-file "\n" nil "~/clock-in-title")
;; )

;; (add-hook 'org-clock-out-hook 'write-clock-out-title-hook)

;;;;  Hook for org-pomodoro
(add-hook 'org-pomodoro-finished-hook
          (lambda ()
            (interactive)
            (start-process "fehab" nil "~/Dropbox/Scripts/./fehb.sh")
            ))
(add-hook 'org-pomodoro-started-hook
          (lambda ()
            (interactive)
            (start-process "feha" nil "~/Dropbox/Scripts/./feha.sh")
            ;; (async-start-process "fehao" "~/Dropbox/Scripts/./feha.sh" nil)
            ))
(add-hook 'org-pomodoro-break-finished-hook
          (lambda ()
            (interactive)
            (start-process "fehac" nil "~/Dropbox/Scripts/./fehc.sh")
            ))
;; SPC keybinds
(map! :leader
     (:prefix-map ("r" . "run")
        :desc "run pomodoro"                                                      "p" #'org-pomodoro
        ))

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
