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

(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
; ;; (add-to-list 'default-frame-alist '(ns-appearance . dark))

(add-hook 'json-mode-hook
          (lambda ()
            (make-local-variable 'js-indent-level)
            (setq js-indent-level 2)))

;; 统一 Corfu 的确认行为：RET 只确认候选，不顺手换行
(setq +corfu-want-ret-to-confirm t)

(after! typescript-ts-mode
  (setq typescript-ts-mode-indent-offset 2))

(after! js2-mode
  (setq js2-basic-offset 2))

(after! web-mode
  ;; 额外让 wxml 也用 web-mode
  (add-to-list 'auto-mode-alist '("\\.wxml\\'" . web-mode))

  ;; 统一 2 空格缩进
  (setq web-mode-markup-indent-offset 2
        web-mode-css-indent-offset 2
        web-mode-code-indent-offset 2))

;; JSX/TSX: 让 emmet-mode 真正支持 tsx-ts-mode，而不是只支持旧的 rjsx-mode
(after! emmet-mode
  (add-to-list 'emmet-jsx-major-modes 'tsx-ts-mode)
  (add-hook 'tsx-ts-mode-hook #'emmet-mode)

  ;; 在 JSX/TSX 里，TAB 的行为和 web-mode 保持一致：
  ;; 优先缩进；在行尾时优先 snippet / emmet 展开。
  (map! :map tsx-ts-mode-map
        :gi "TAB"   #'+web/indent-or-yas-or-emmet-expand
        :gi "<tab>" #'+web/indent-or-yas-or-emmet-expand))
