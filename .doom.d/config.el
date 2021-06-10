(define-key key-translation-map (kbd "SPC m c c") (kbd "C-c C-c"))
(define-key key-translation-map (kbd "SPC m c k") (kbd "C-c C-k"))

(setq doom-font (font-spec :family "Monaco" :size 14 :weight 'semi-light)
      doom-variable-pitch-font (font-spec :family "Monaco") ; inherits `doom-font''s :size
      doom-unicode-font (font-spec :family "Monaco" :size 14)
      doom-big-font (font-spec :family "Monaco" :size 22))

(map! :en "C-h"       #'evil-window-left
      :en "C-j"       #'evil-window-down
      :en "C-k"       #'evil-window-up
      :en "C-l"       #'evil-window-right
      :en "M-."       #'tide-jump-to-definition
      :en "M-,"       #'tide-jump-back
      :en "C-["       #'evil-force-normal-state
      :en "SPC f f"   #'counsel-find-file)

(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
; ;; (add-to-list 'default-frame-alist '(ns-appearance . dark))

(add-hook 'json-mode-hook
          (lambda ()
            (make-local-variable 'js-indent-level)
            (setq js-indent-level 2)))

(remove-hook! js2-mode #'+javascript|init-tide)

(add-hook 'c++-mode-hook
          (lambda ()
            (setq flycheck-gcc-language-standard "c++11"
                  flycheck-clang-language-standard "c++11")))

(use-package! web-mode
  :mode ("\\.vue\\'" "\\.wxml\\'")
  :config
  ;; 这里就是设置一下缩进为2个空格
  (setq web-mode-indent-level 2)
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2))

