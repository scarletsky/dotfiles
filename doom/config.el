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

(map! :n "C-h"       #'evil-window-left
      :n "C-j"       #'evil-window-down
      :n "C-k"       #'evil-window-up
      :n "C-l"       #'evil-window-right
      :n "C-["       #'evil-force-normal-state)

;; 忽略搜索 git submodules 目录
(after! projectile
  (add-to-list 'projectile-globally-ignored-directories "submodules"))

(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
; ;; (add-to-list 'default-frame-alist '(ns-appearance . dark))

(add-hook 'json-mode-hook
          (lambda ()
            (make-local-variable 'js-indent-level)
            (setq js-indent-level 2)))

;;; Better Eglot + Corfu completion ------------------------------------------
;; 统一 Corfu 的确认行为：RET 只确认候选，不顺手换行
(setq +corfu-want-ret-to-confirm t)

(after! corfu
  (setq corfu-preview-current t
        ;; 'valid 更像 VSCode，但更容易误确认；如果不喜欢就改成 'prompt
        corfu-preselect 'valid))

(after! corfu-popupinfo
  (setq corfu-popupinfo-delay '(0.25 . 0.1)
        corfu-popupinfo-max-width 100
        corfu-popupinfo-max-height 20))

(after! eglot
  ;; Eglot 的 completion category 是 eglot-capf。
  ;; Doom 目前只给 lsp-capf 加了 orderless override，所以这里手动补上。
  (add-to-list 'completion-category-overrides
               '(eglot-capf (styles orderless basic)))

  ;; 连续补全时缓存候选，减少请求 language server 的次数。
  (setq eglot-cache-session-completions t
        eglot-send-changes-idle-time 0.2)

  ;; TypeScript / JavaScript 补全增强。
  (setf (plist-get eglot-workspace-configuration :typescript)
        '(:preferences
          (:includePackageJsonAutoImports "on"
           :includeCompletionsForModuleExports t
           :includeCompletionsForImportStatements t
           :includeAutomaticOptionalChainCompletions t
           :includeCompletionsWithSnippetText t)
          :suggest
          (:completeFunctionCalls t))

        (plist-get eglot-workspace-configuration :javascript)
        '(:preferences
          (:includePackageJsonAutoImports "on"
           :includeCompletionsForModuleExports t
           :includeCompletionsForImportStatements t
           :includeAutomaticOptionalChainCompletions t
           :includeCompletionsWithSnippetText t)
          :suggest
          (:completeFunctionCalls t))

        ;; Python auto import 补全。
        (plist-get eglot-workspace-configuration :python)
        '(:analysis
          (:autoImportCompletions t)))

  ;; JS / TS / TSX：明确使用 typescript-language-server。
  (set-eglot-client! '((js-mode :language-id "javascript")
                       (js-ts-mode :language-id "javascript")
                       (typescript-mode :language-id "typescript")
                       (typescript-ts-mode :language-id "typescript")
                       (tsx-ts-mode :language-id "typescriptreact"))
                     '("typescript-language-server" "--stdio"))

  ;; HTML / CSS：需要 pnpm add -D vscode-langservers-extracted。
  (set-eglot-client! '((html-mode :language-id "html")
                       (html-ts-mode :language-id "html"))
                     '("vscode-html-language-server" "--stdio"))

  (set-eglot-client! '((css-mode :language-id "css")
                       (css-ts-mode :language-id "css"))
                     '("vscode-css-language-server" "--stdio"))

  ;; Python：如果你安装了 pyright。
  (when (executable-find "pyright-langserver")
    (set-eglot-client! '(python-mode python-ts-mode)
                       '("pyright-langserver" "--stdio")))

  ;; C/C++：clangd 补全更详细。
  (when (executable-find "clangd")
    (set-eglot-client! '(c-mode c-ts-mode c++-mode c++-ts-mode objc-mode)
                       '("clangd"
                         "--background-index"
                         "--clang-tidy"
                         "--completion-style=detailed"))))

;;; GLSL ----------------------------------------------------------------------
;; 背景：
;; - Doom 的 `(cc +tree-sitter)' 会把 `glsl-mode' 自动 remap 到
;;   `glsl-ts-mode'。
;; - 但当前 glsl-mode 包里的 `glsl-ts-mode' 和 Emacs 30.2 自带的
;;   `c-ts-mode' API 不兼容：它调用了内部函数
;;   `c-ts-mode--simple-indent-rules'，而这个函数在 Emacs 30.2 中不存在。
;;   结果是 `glsl-ts-setup' 中途报错，GLSL 文件没有语法高亮。
;; - 传统的 `glsl-mode' 工作正常，并且有普通 font-lock 语法高亮。
;;
;; 暂时让 GLSL 文件继续使用传统 `glsl-mode'。这里用用户级 remap 覆盖
;; Doom 的默认 remap，但不删除 Doom 的默认配置，方便以后恢复：等
;; `glsl-ts-mode' 兼容后，删掉下面这一行即可。
(add-to-list 'major-mode-remap-alist '(glsl-mode . glsl-mode))

;; Doom 的 `(cc +lsp)' 还会给 GLSL mode hook 自动加入 `lsp!'。当前配置使用
;; `:tools (lsp +eglot +booster)'，所以它会尝试为 GLSL 启动 Eglot。
;; 但现在没有配置可用的 GLSL language server，可能出现：
;;   [eglot] Wrong type argument: processp, nil
;; 目前我只需要 GLSL 语法高亮，所以关闭 GLSL 的自动 LSP。以后如果配置了
;; GLSL language server，可以删掉下面这两个 `remove-hook'。
(after! glsl-mode
  (remove-hook 'glsl-mode-local-vars-hook #'lsp!)
  (remove-hook 'glsl-ts-mode-local-vars-hook #'lsp!))

;;; JavaScript / TypeScript / Web ---------------------------------------------
;; Tree-sitter grammar 安装、mode remap 和 fallback 交给 Doom 的
;; `:tools tree-sitter' 与 `:lang javascript' 模块处理。这里仅保留个人编辑偏好。
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

;; 复用系统 Rime 的配置和词库
;; 不要自动编译 rime，改成手动
;;   cd ~/.config/emacs/.local/straight/build-30.2/liberime
;;   make clean && make -B
;;; Rime / pyim ---------------------------------------------------------------
(after! pyim
  ;; pyim 自己控制候选框，不读取鼠须管候选框设置。
  (setq pyim-page-length 9
        pyim-page-style 'vertical
        pyim-page-tooltip 'posframe))

(after! liberime
  ;; 共用鼠须管的 Rime 用户配置和词库。
  (setq liberime-auto-build nil
        liberime-user-data-dir "~/Library/Rime/")

  ;; 明确选择你系统里正在用的 Rime schema。
  ;; 如果你实际用小鹤混输，改成 "rime_mint_flypy"。
  (liberime-try-select-schema "rime_mint")

  ;; 让 Emacs 里的 Rime session 也切到简体。
  ;; 你的 rime_mint.schema.yaml 用的是 transcription 这个开关：
  ;;   states: [ 简体, 繁体 ]
  ;; reset: 0 本来应是简体，但为了避免 session 状态不同，这里显式按一次切换键。
  ;; 如果执行后反而变繁体，就删掉这行，或在 Emacs 中按 C-` 打开方案菜单切回简体。
  ;; (liberime-simulate-key-sequence "{Control+Shift+4}")
  )
