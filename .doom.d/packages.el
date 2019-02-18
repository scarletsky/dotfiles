(package! posframe)
(package! org-projectile)
(package! glsl-mode)
(package! pyim)
(package! pyim-basedict)
(package! magit :recipe
    (:fetcher github
     :repo "magit/magit"
     :commit "78114e6425d5e7d6eaa7712c845f28694aa7faeb"
     :files ("lisp/magit"
             "lisp/magit*.el"
             "lisp/git-rebase.el")))
