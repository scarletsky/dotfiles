(def-package! glsl-mode
  :mode (("\\.frag\\'"  . glsl-mode)
         ("\\.vert\\'"  . glsl-mode)))

(def-package! org-projectile
  :after org
  :config
  (progn
    (org-projectile-per-project)
    (setq org-projectile-per-project-filepath "TODOs.org")
    (setq org-agenda-files (append org-agenda-files (org-projectile-todo-files)))
    (push (org-projectile-project-todo-entry) org-capture-templates)))

(def-package! pyim
  :ensure nil
  :config
  ;; 激活 basedict 拼音词库，五笔用户请继续阅读 README
  (use-package pyim-basedict
    :ensure nil
    :config (pyim-basedict-enable))

  (setq default-input-method "pyim")

  ;; 我使用全拼
  (setq pyim-default-scheme 'quanpin)

  ;; 设置 pyim 探针设置，这是 pyim 高级功能设置，可以实现 *无痛* 中英文切换 :-)
  ;; 我自己使用的中英文动态切换规则是：
  ;; 1. 光标只有在注释里面时，才可以输入中文。
  ;; 2. 光标前是汉字字符时，才能输入中文。
  ;; 3. 使用 M-j 快捷键，强制将光标前的拼音字符串转换为中文。
  (setq-default pyim-english-input-switch-functions
                '(pyim-probe-dynamic-english
                  pyim-probe-isearch-mode
                  pyim-probe-program-mode
                  pyim-probe-org-structure-template))

  (setq-default pyim-punctuation-half-width-functions
                '(pyim-probe-punctuation-line-beginning
                  pyim-probe-punctuation-after-punctuation))

  ;; 开启拼音搜索功能
  (pyim-isearch-mode 1)

  ;; 使用 pupup-el 来绘制选词框, 如果用 emacs26, 建议设置
  ;; 为 'posframe, 速度很快并且菜单不会变形，不过需要用户
  ;; 手动安装 posframe 包。
  ;; (setq pyim-page-tooltip 'popup)
  (setq pyim-page-tooltip 'posframe)

  ;; 选词框显示5个候选词
  (setq pyim-page-length 5)

  :bind
  (("M-j" . pyim-convert-string-at-point) ;与 pyim-probe-dynamic-english 配合
   ("C-;" . pyim-delete-word-from-personal-buffer)))


(defun offlineimap-get-password (host port)
  (require 'netrc)
  (let* ((netrc (netrc-parse (expand-file-name "~/.authinfo.gpg")))
         (hostentry (netrc-machine netrc host port port)))
    (when hostentry (netrc-get hostentry "password"))))

(defun npm-deploy-internal ()
  "Runs: npm run deploy:internal"
  (interactive)
  (async-shell-command "npm run deploy:internal"))

(defun npm-deploy-staging ()
  "Runs: npm run deploy:staging"
  (interactive)
  (async-shell-command "npm run deploy:staging"))

(defun npm-deploy-production ()
  "Runs: npm run deploy:production"
  (interactive)
  (async-shell-command "npm run deploy:production"))

(define-key key-translation-map (kbd "SPC f f") (kbd "C-x C-f"))
(define-key key-translation-map (kbd "SPC m c c") (kbd "C-c C-c"))
(define-key key-translation-map (kbd "SPC m c k") (kbd "C-c C-k"))

(global-set-key (kbd "C-c d i") 'npm-deploy-internal)
(global-set-key (kbd "C-c d s") 'npm-deploy-staging)
(global-set-key (kbd "C-c d p") 'npm-deploy-production)

(map! :en "C-h"   #'evil-window-left
      :en "C-j"   #'evil-window-down
      :en "C-k"   #'evil-window-up
      :en "C-l"   #'evil-window-right
      :en "M-."   #'tide-jump-to-definition
      :en "M-,"   #'tide-jump-back)

(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
; ;; (add-to-list 'default-frame-alist '(ns-appearance . dark))

(add-hook 'json-mode-hook
          (lambda ()
            (make-local-variable 'js-indent-level)
            (setq js-indent-level 2)))

(remove-hook! js2-mode #'+javascript|init-tide)
