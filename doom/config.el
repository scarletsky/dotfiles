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

;; Doom 的 Vertico 项目搜索直接使用 Consult/ripgrep，不读取 Projectile 的
;; ignored-directories 配置；显式排除任意层级的 submodules/ 目录。
(defun my/consult-ripgrep-exclude-submodules (orig-fn paths)
  (let ((consult-ripgrep-args
         (concat consult-ripgrep-args
                 " --glob=!**/submodules/**")))
    (funcall orig-fn paths)))

(after! consult
  (advice-add #'consult--ripgrep-make-builder
              :around #'my/consult-ripgrep-exclude-submodules))


;;; File types ----------------------------------------------------------------

(setq-hook! 'json-mode-hook
  js-indent-level 2)


;;; Indentation ---------------------------------------------------------------

;; Doom 的全局默认是 4 空格（`tab-width' = 4）。Emacs 内置的 JavaScript
;; mode 默认也是 `js-indent-level' = 4，`js-ts-mode' 也使用这个变量。
;;
;; 不要在这里把 JS 缩进写死成 2 或 4；优先让 EditorConfig 或
;; `:editor (whitespace +guess)' 按项目配置 / 文件已有缩进，在 buffer 内局部覆盖。
;; Doom 默认不在项目内猜缩进，而我的项目不一定都有 .editorconfig，所以显式开启。
(setq +whitespace-guess-in-projects t)

(after! editorconfig
  ;; 显式声明普通 JS mode 和 tree-sitter JS mode 的缩进变量。
  ;; 目前 upstream editorconfig-emacs 已经知道这些映射；这里保留是为了让意图
  ;; 更清楚，也避免以后 mode remap、tree-sitter 或继承关系变化导致失效。
  (dolist (entry '((js-mode js-indent-level)
                   (js-ts-mode js-indent-level)))
    (setf (alist-get (car entry) editorconfig-indentation-alist)
          (cdr entry))))


;;; Completion / LSP ----------------------------------------------------------

;; 普通 buffer 中：RET 只确认 Corfu 候选，不顺手换行。
;; minibuffer 中：RET 确认候选后继续提交 minibuffer，避免 Evil `/` 搜索需要按两次 RET。
(setq +corfu-want-ret-to-confirm 'minibuffer)

(after! corfu
  (setq corfu-preview-current nil
        ;; 不显示 inline preview，只在弹窗列表中高亮当前候选。
        ;; 这样 TAB/S-TAB 只是“选择候选”，不会在 buffer 里显示 overlay 假文本，
        ;; 避免误以为候选已经被真正插入。
        ;;
        ;; 不预选第一个候选，先停在 prompt。
        ;; 这样 popup 出来时不会因为误按 RET 而接受第一项。
        ;; 按 TAB 后才开始选择候选，按 RET 才真正确认。
        corfu-preselect 'prompt)

  ;; ESC 只负责关闭/取消 Corfu，不接受候选。
  ;; 这样符合大多数编辑器直觉：TAB/S-TAB 只是选择，RET 才确认，ESC 取消。
  ;; 同时避免 Corfu 默认的 `corfu-reset' 把 selection/preview 回滚造成困惑。
  (map! :map corfu-map
        [escape] #'corfu-quit
        [remap keyboard-escape-quit] #'corfu-quit)

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

;; `eglot-typescript-preset' 会自动 setup；这里先关闭，等我们设好 Vue/rass
;; 相关变量后再手动 setup。
(setq eglot-typescript-preset-auto-setup nil)

(after! eglot
  (require 'eglot-typescript-preset)

  ;; Vue SFC 通过 `my/vue-mode' 进入 Eglot，并由 rass 组合 Volar 与 TS server。
  (add-to-list 'eglot-typescript-preset-language-id-overrides
               '(my/vue-mode . "vue"))
  (setq eglot-typescript-preset-vue-modes '(my/vue-mode)
        eglot-typescript-preset-vue-lsp-server 'rass
        ;; 先只启用 Vue + TypeScript，避免 Tailwind 等额外 server 增加排错复杂度。
        eglot-typescript-preset-vue-rass-tools
        '(vue-language-server typescript-language-server)
        eglot-typescript-preset-tsdk
        (expand-file-name "~/.config/doom/npm/node_modules/typescript/lib"))
  (eglot-typescript-preset-setup)

  ;; 防御性地显式注册一次 my/vue-mode。这样即使在未重启 Emacs、preset 曾经
  ;; 用默认 vue-mode/vue-ts-mode 提前 setup 过的情况下，.vue 也能找到 client，
  ;; 不会落到 contact=nil 进而触发 "Wrong type argument: processp, nil"。
  (add-to-list 'eglot-server-programs
               '(((my/vue-mode :language-id "vue"))
                 . eglot-typescript-preset--vue-server-contact))

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

(autoload 'web-mode "web-mode")

(define-derived-mode my/vue-mode web-mode "Vue"
  "Major mode for Vue single-file components."
  (setq-local web-mode-engine "vue"))

;; Doom 默认把 .vue 放进 web-mode。这里给 Vue SFC 单独的 mode，避免所有
;; web-mode buffer 都误用 Volar/rass。先删掉已有 .vue 关联，避免 Doom/web-mode
;; 的规则排在前面时仍然进入 web-mode。
(defun my/vue-file-p ()
  "Return non-nil if the current buffer visits a .vue file."
  (and buffer-file-name
       (string-match-p "\\.vue\\'" buffer-file-name)))

(defun my/register-vue-mode-h ()
  "Make .vue files use `my/vue-mode' instead of plain `web-mode'."
  (setq auto-mode-alist
        (cl-remove-if (lambda (entry)
                        (and (stringp (car-safe entry))
                             (string-match-p "\\\\.vue" (car entry))))
                      auto-mode-alist))
  (add-to-list 'auto-mode-alist '("\\.vue\\'" . my/vue-mode)))

(defvar my/vue-mode--redirecting nil)
(defun my/vue-mode-from-web-mode-h ()
  "Fallback: if a .vue file still entered plain `web-mode', switch to Vue mode."
  (when (and (not my/vue-mode--redirecting)
             (eq major-mode 'web-mode)
             (my/vue-file-p))
    (let ((my/vue-mode--redirecting t))
      (my/vue-mode))))

(my/register-vue-mode-h)
(add-hook 'doom-after-init-hook #'my/register-vue-mode-h)
(add-hook 'web-mode-hook #'my/vue-mode-from-web-mode-h)

;; 正常情况下 Doom 会在 `my/vue-mode-local-vars-hook' 里启动 LSP；但当 .vue
;; 先被 Doom 分到 web-mode、再由 `web-mode-hook' 兜底切到 my/vue-mode 时，
;; local-vars hook 的时机可能已经错过。这里同时挂普通 mode hook，保证 Eglot
;; 会启动。
(add-hook 'my/vue-mode-hook #'lsp! 'append)
(add-hook 'my/vue-mode-local-vars-hook #'lsp! 'append)

;; Tree-sitter grammar 安装、mode remap 和 fallback 交给 Doom 的
;; `:tools tree-sitter' 与 `:lang javascript' 模块处理。这里仅保留个人编辑偏好。
(after! web-mode
  ;; 额外让 wxml 也用 web-mode。
  (add-to-list 'auto-mode-alist '("\\.wxml\\'" . web-mode))

  ;; web-mode 默认会给 <script> / <style> 这类 part 内容额外加 1 个空格的
  ;; padding。这个额外 padding 容易和按文件猜出来的缩进宽度叠加，比如
  ;; 2 空格文件里变成 3 空格。统一关掉它，只让各类 indent offset 决定缩进宽度。
  (setq web-mode-part-padding 0
        web-mode-script-padding 0
        web-mode-style-padding 0))

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

;; 已禁用 Doom 的 pyim + liberime/rime 配置。
;;
;; 背景：之前 Emacs liberime 和系统鼠须管都指向 ~/Library/Rime/，会共用并同时
;; 读写 rime_mint.userdb / melt_eng.userdb。Rime 用户词库底层是 LevelDB，不适合
;; 多个进程同时写同一个数据库目录；这可能导致用户词频库损坏、候选排序回退。
;;
;; 现在中文输入统一交给系统鼠须管。若以后要恢复 Emacs 内置 Rime，请不要再把
;; liberime-user-data-dir 指向 ~/Library/Rime/；应使用独立目录，例如：
;; ~/.local/share/rime-emacs/，再通过导出/同步方式交换词频。
;;
;; 原配置保留如下，按需参考：
;;
;; ;; 复用系统 Rime 的配置和词库。不要自动编译 rime，改成手动：
;; ;;   cd ~/.config/emacs/.local/straight/build-30.2/liberime
;; ;;   make clean && make -B
;; (setq liberime-auto-build nil
;;       liberime-shared-data-dir "~/Library/Rime/"
;;       liberime-user-data-dir "~/Library/Rime/")
;;
;; (after! pyim
;;   ;; pyim 自己控制候选框，不读取鼠须管候选框设置。
;;   (setq pyim-page-length 9
;;         pyim-page-style 'vertical
;;         pyim-page-tooltip 'posframe))
;;
;; (after! evil-pinyin
;;   ;; 关闭 Evil / ? n N 的拼音搜索扩展，避免把搜索内容展开成大量中文 regexp。
;;   (setq-default evil-pinyin-with-search-rule 'never))
;;
;; (after! liberime
;;   ;; 明确选择系统里正在用的 Rime schema。如果实际用小鹤混输，改成
;;   ;; "rime_mint_flypy"。
;;   (liberime-try-select-schema "rime_mint"))
;;
;; ;; 如需手动切换简繁，可在 Emacs 中用 Rime 的方案菜单，或临时执行：
;; ;; (liberime-simulate-key-sequence "{Control+Shift+4}")


