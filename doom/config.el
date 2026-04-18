;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "John Doe"
      user-mail-address "john@doe.com")

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
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-dark+)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


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

(define-key key-translation-map (kbd "SPC m c c") (kbd "C-c C-c"))
(define-key key-translation-map (kbd "SPC m c k") (kbd "C-c C-k"))
(setenv "HTTP_PROXY" "http://127.0.0.1:7899")
(setenv "HTTPS_PROXY" "http://127.0.0.1:7899")
(setq url-proxy-services
      '(("http" . "127.0.0.1:7899")
        ("https" . "127.0.0.1:7899")
        ("no_proxy" . "^\\(localhost\\|10\\..*\\|192\\.168\\..*\\)")))

(setq doom-font (font-spec :family "Monaco" :size 14 :weight 'semi-light)
      doom-variable-pitch-font (font-spec :family "Monaco") ; inherits `doom-font''s :size
      doom-unicode-font (font-spec :family "Monaco" :size 14)
      doom-big-font (font-spec :family "Monaco" :size 22))

(setenv "PATH" (concat (expand-file-name "~/.config/doom/npm/node_modules/.bin") path-separator (getenv "PATH")))
(add-to-list 'exec-path (expand-file-name "~/.config/doom/npm/node_modules/.bin"))

(defun my/find-executable (program)
  "Find PROGRAM in the system path."
  (interactive "sProgram name: ")
  (message "%s" (or (executable-find program)
                    "Not found")))

(map! :en "C-h"       #'evil-window-left
      :en "C-j"       #'evil-window-down
      :en "C-k"       #'evil-window-up
      :en "C-l"       #'evil-window-right
      :en "C-["       #'evil-force-normal-state
      :en "SPC f f"   #'counsel-find-file)


;; 忽略搜索 git submodules 目录
(after! projectile
  (add-to-list 'projectile-globally-ignored-directories "submodules"))

;; cc-mode 和 glsl-mode 中会使用 `C-h/j/k/l` 快捷键，和全局快捷键冲突
(after! ccls
  (map! :map (c-mode-map c++-mode-map)
        :n "C-h" #'evil-window-left
        :n "C-j" #'evil-window-down
        :n "C-k" #'evil-window-up
        :n "C-l" #'evil-window-right
        :n "M-h" (cmd! (ccls-navigate "U"))
        :n "M-j" (cmd! (ccls-navigate "R"))
        :n "M-k" (cmd! (ccls-navigate "L"))
        :n "M-l" (cmd! (ccls-navigate "D"))))

(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
; ;; (add-to-list 'default-frame-alist '(ns-appearance . dark))

(add-hook 'json-mode-hook
          (lambda ()
            (make-local-variable 'js-indent-level)
            (setq js-indent-level 2)))

(after! flycheck
  (flycheck-define-error-level 'lsp-flycheck-info-unnecessary
    :severity 'info
    :compilation-level 0
    :overlay-category 'flycheck-info-overlay
    :fringe-bitmap 'flycheck-fringe-bitmap-double-arrow
    :fringe-face 'flycheck-fringe-info
    :error-list-face 'flycheck-error-list-info))

(after! js2-mode
  (setq js2-basic-offset 2))

(after! rjsx-mode
  (setq js2-basic-offset 2))

(use-package! web-mode
  ;:mode ("\\.vue\\'" "\\.wxml\\'")
  :mode ("\\.wxml\\'")
  :config
  ;; 这里就是设置一下缩进为2个空格
  (setq web-mode-indent-level 2)
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2))

;; ====== lsp-mode 配置 ======

(after! lsp-mode
  ;; 忽略搜索 submodules
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]submodules"))

(after! lsp-javascript
  ;; 优先使用当前项目的 TypeScript SDK，避免跨 workspace 复用其他项目的 tsserver。
  (setq lsp-clients-typescript-prefer-use-project-ts-server t))

(after! lsp-volar
  (defun my/lsp-volar--same-root-p (a b)
    (and a b
         (string= (file-truename (directory-file-name a))
                  (file-truename (directory-file-name b)))))

  (defun my/lsp-volar--find-ts-workspace (root)
    (cl-find-if
     (lambda (workspace)
       (and (eq (lsp--client-server-id (lsp--workspace-client workspace))
                lsp-volar-typescript-server-id)
            (my/lsp-volar--same-root-p root (lsp--workspace-root workspace))))
     (lsp--session-workspaces (lsp-session))))

  (defun lsp-volar--tsserver-request-handler (volar-workspace params)
    "Forward Volar tsserver requests to the TypeScript workspace with the same root."
    (if-let* ((root (lsp--workspace-root volar-workspace))
              (ts-ls-workspace (my/lsp-volar--find-ts-workspace root)))
        (with-lsp-workspace ts-ls-workspace
          (-let [[[id command payload]] params]
            (lsp-request-async
             "workspace/executeCommand"
             (list :command "typescript.tsserverRequest"
                   :arguments (vector command payload))
             (lambda (response)
               (let ((body (lsp-get response :body)))
                 (lsp-volar--send-notify
                  volar-workspace
                  "tsserver/response"
                  (vector (vector id body)))))
             :error-handler
             (lambda (error-response)
               (lsp--warn "tsserver/request async error: %S" error-response)))))
      (lsp--error "[lsp-volar] Could not find `%s` lsp client for %s"
                  lsp-volar-typescript-server-id
                  (or (lsp--workspace-root volar-workspace) "<unknown root>")))))

;; persp-mode + lsp-mode：自动重连断开的 LSP，并在关闭 workspace 时回收 orphan workspaces
(after! (persp-mode lsp-mode)
  (setq +lsp-defer-shutdown 30)

  (add-hook! 'persp-activated-functions
    (defun my/lsp-restart-on-workspace-switch-h (&rest _)
      (when-let* ((persp (get-current-persp))
                  (persp-name (safe-persp-name persp)))
        (run-with-idle-timer
         0 nil
         (lambda (name)
           (when-let ((current (get-current-persp)))
             (when (equal name (safe-persp-name current))
               (dolist (buf (persp-buffers current))
                 (when (buffer-live-p buf)
                   (with-current-buffer buf
                     (when (and (bound-and-true-p lsp-mode)
                                (buffer-file-name)
                                (not (file-remote-p default-directory))
                                (null (lsp-workspaces)))
                       (with-demoted-errors "LSP reconnect error: %S"
                         (lsp-deferred)))))))))
         persp-name))))

  (add-hook! 'persp-before-kill-functions
    (defun my/lsp-shutdown-orphaned-workspaces-h (persp)
      (let (workspaces)
        (dolist (buf (persp-buffers persp))
          (when (buffer-live-p buf)
            (with-current-buffer buf
              (when (bound-and-true-p lsp-mode)
                (dolist (ws (lsp-workspaces))
                  (cl-pushnew ws workspaces))))))

        ;; 这个 hook 触发时，persp 里的 buffer 还没真正移除；
        ;; 所以延后一拍再检查哪些 workspace 已经变成 orphan。
        (when workspaces
          (run-at-time
           0 nil
           (lambda (wss)
             (dolist (ws wss)
               (unless (cl-some #'lsp-buffer-live-p
                                (lsp--workspace-buffers ws))
                 (with-demoted-errors "LSP shutdown error: %S"
                   (let ((+lsp-defer-shutdown 0))
                     (lsp-workspace-shutdown ws))))))
           workspaces))))))
