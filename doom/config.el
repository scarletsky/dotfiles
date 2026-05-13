;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-
;;; Commentary:
;; Personal Doom Emacs configuration.
;;; Code:

;;; UI ------------------------------------------------------------------------

(setq doom-theme 'doom-dark+
      display-line-numbers-type t
      org-directory "~/org/"
      doom-font (font-spec :family "Monaco" :size 14 :weight 'semi-light)
      doom-variable-pitch-font (font-spec :family "Monaco")
      doom-unicode-font (font-spec :family "Monaco" :size 14)
      doom-big-font (font-spec :family "Monaco" :size 22))

(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
;; (add-to-list 'default-frame-alist '(ns-appearance . dark))


;;; Environment ---------------------------------------------------------------

(setenv "HTTP_PROXY" "http://127.0.0.1:7899")
(setenv "HTTPS_PROXY" "http://127.0.0.1:7899")
(setq url-proxy-services
      '(("http" . "127.0.0.1:7899")
        ("https" . "127.0.0.1:7899")
        ("no_proxy" . "^\\(localhost\\|10\\..*\\|192\\.168\\..*\\)")))

(let ((doom-npm-bin (expand-file-name "~/.config/doom/npm/node_modules/.bin")))
  (setenv "PATH" (concat doom-npm-bin path-separator (getenv "PATH")))
  (add-to-list 'exec-path doom-npm-bin))

(defun my/find-executable (program)
  "Find PROGRAM in the system path."
  (interactive "sProgram name: ")
  (message "%s" (or (executable-find program)
                    "Not found")))


;;; Keybindings ---------------------------------------------------------------

(define-key key-translation-map (kbd "SPC m c c") (kbd "C-c C-c"))
(define-key key-translation-map (kbd "SPC m c k") (kbd "C-c C-k"))

(map! :n "C-h" #'evil-window-left
      :n "C-j" #'evil-window-down
      :n "C-k" #'evil-window-up
      :n "C-l" #'evil-window-right
      :n "C-[" #'evil-force-normal-state)


;;; Project -------------------------------------------------------------------

(after! projectile
  ;; 忽略搜索 git submodules 目录。
  (add-to-list 'projectile-globally-ignored-directories "submodules"))


;;; File types ----------------------------------------------------------------

(setq-hook! 'json-mode-hook
  js-indent-level 2)


;;; Completion / LSP ----------------------------------------------------------

;; 统一 Corfu 的确认行为：RET 只确认候选，不顺手换行。
(setq +corfu-want-ret-to-confirm t)

(after! corfu
  (setq corfu-preview-current t
        ;; 'valid 更像 VSCode，但更容易误确认；如果不喜欢就改成 'prompt。
        corfu-preselect 'valid)

  ;; VSCode Dark 风格的补全弹窗配色。
  (custom-set-faces!
    '(corfu-default
      :background "#252526"
      :foreground "#cccccc")
    '(corfu-current
      :background "#264f78"
      :foreground "#ffffff"
      :weight bold
      :extend t)
    '(corfu-border
      :background "#454545")
    '(corfu-bar
      :background "#797979")
    '(corfu-annotations
      :foreground "#8c8c8c")
    '(corfu-deprecated
      :foreground "#8c8c8c"
      :strike-through t)))

(after! corfu-popupinfo
  (setq corfu-popupinfo-delay '(0.25 . 0.1)
        corfu-popupinfo-max-width 100
        corfu-popupinfo-max-height 20)

  (custom-set-faces!
    '(corfu-popupinfo
      :background "#1e1e1e"
      :foreground "#cccccc")))

(after! eglot
  ;; Eglot 的 completion category 是 eglot-capf。Doom 目前只给 lsp-capf 加了
  ;; orderless override，所以这里手动补上。
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

  ;; Python：如果安装了 pyright。
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
;; - 但当前 glsl-mode 包里的 `glsl-ts-mode' 和 Emacs 30.2 自带的 `c-ts-mode'
;;   API 不兼容：它调用了内部函数 `c-ts-mode--simple-indent-rules'，而这个
;;   函数在 Emacs 30.2 中不存在。结果是 `glsl-ts-setup' 中途报错，GLSL 文件
;;   没有语法高亮。
;; - 传统的 `glsl-mode' 工作正常，并且有普通 font-lock 语法高亮。
;;
;; 暂时让 GLSL 文件继续使用传统 `glsl-mode'。这里用用户级 remap 覆盖 Doom
;; 的默认 remap，但不删除 Doom 的默认配置，方便以后恢复：等 `glsl-ts-mode'
;; 兼容后，删掉下面这一行即可。
(add-to-list 'major-mode-remap-alist '(glsl-mode . glsl-mode))

;; Doom 的 `(cc +lsp)' 还会给 GLSL mode hook 自动加入 `lsp!'。当前配置使用
;; `:tools (lsp +eglot +booster)'，所以它会尝试为 GLSL 启动 Eglot。但现在没有
;; 配置可用的 GLSL language server，可能出现：
;;   [eglot] Wrong type argument: processp, nil
;; 目前只需要 GLSL 语法高亮，所以关闭 GLSL 的自动 LSP。以后如果配置了 GLSL
;; language server，可以删掉下面这两个 `remove-hook'。
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
  ;; 额外让 wxml 也用 web-mode。
  (add-to-list 'auto-mode-alist '("\\.wxml\\'" . web-mode))

  ;; 统一 2 空格缩进。
  (setq web-mode-markup-indent-offset 2
        web-mode-css-indent-offset 2
        web-mode-code-indent-offset 2))

(after! emmet-mode
  ;; JSX/TSX: 让 emmet-mode 真正支持 tsx-ts-mode，而不是只支持旧的 rjsx-mode。
  (add-to-list 'emmet-jsx-major-modes 'tsx-ts-mode)
  (add-hook 'tsx-ts-mode-hook #'emmet-mode)

  ;; 在 JSX/TSX 里，TAB 的行为和 web-mode 保持一致：优先缩进；在行尾时优先
  ;; snippet / emmet 展开。
  (map! :map tsx-ts-mode-map
        :gi "TAB" #'+web/indent-or-yas-or-emmet-expand
        :gi "<tab>" #'+web/indent-or-yas-or-emmet-expand))


;;; Rime / pyim ---------------------------------------------------------------

;; 复用系统 Rime 的配置和词库。不要自动编译 rime，改成手动：
;;   cd ~/.config/emacs/.local/straight/build-30.2/liberime
;;   make clean && make -B
(setq liberime-auto-build nil
      liberime-shared-data-dir "~/Library/Rime/"
      liberime-user-data-dir "~/Library/Rime/")

(after! pyim
  ;; pyim 自己控制候选框，不读取鼠须管候选框设置。
  (setq pyim-page-length 9
        pyim-page-style 'vertical
        pyim-page-tooltip 'posframe))

(after! evil-pinyin
  ;; 关闭 Evil / ? n N 的拼音搜索扩展，避免把搜索内容展开成大量中文 regexp。
  (setq-default evil-pinyin-with-search-rule 'never))

(after! liberime
  ;; 明确选择系统里正在用的 Rime schema。如果实际用小鹤混输，改成
  ;; "rime_mint_flypy"。
  (liberime-try-select-schema "rime_mint"))

;; 如需手动切换简繁，可在 Emacs 中用 Rime 的方案菜单，或临时执行：
;; (liberime-simulate-key-sequence "{Control+Shift+4}")

