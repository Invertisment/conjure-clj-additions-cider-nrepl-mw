(module conjure-clj-additions.load-util
  {require {nvim conjure.aniseed.nvim
            str conjure.aniseed.string
            bridge conjure.bridge
            config conjure.config
            fns conjure-clj-additions.additional-fns}})

(defn try-load! [match-filetype retries is-loaded-fn try-load-fn]
  (when (= match-filetype vim.bo.filetype)
    ; https://vi.stackexchange.com/questions/33056/how-to-use-vim-loop-interactively-in-neovim
    (var i 0)
    (var skip false)
    (let [timer (vim.loop.new_timer) ]
      (timer:start
        500 ; wait for 500 ms and attempt the first callback
        100 ; time between attempts
        (fn []
          ((vim.schedule_wrap (fn [] (try-load-fn))))
          (if skip
            nil
            (if (or (is-loaded-fn) (not (>= i retries)))
              (do
                (set skip true)
                (timer:close))
              (set i (+ 1 i)))))))))
