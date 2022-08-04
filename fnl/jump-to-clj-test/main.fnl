(module jump-to-clj-test.main
  {require {nvim conjure.aniseed.nvim
            str conjure.aniseed.string
            bridge conjure.bridge}})

(defn bind [mode ]
  )

(defn on-filetype []
  (nvim.echo "mm on-filetype")
  ;;(nvim.buf_set_keymap 0 "n" "<locallleader>tf"  {:silent true :noremap true})
  ;;(buf :n :LogSplit (cfg :log_split) :conjure.log :split)
  ;;api.nvim_buf_set_keymap(0, "n", "<locallleader>tf", "lua show_diagnostics_details()", opts)
  )

(defn init-mappings! []
  (nvim.ex.augroup :jump_to_clj_test_init_filetypes)
  (nvim.ex.autocmd_)
  (nvim.ex.autocmd
    :FileType (str.join "," [:clojure])
    (bridge.viml->lua :jump-to-clj-test.main :on-filetype {}))
  (nvim.ex.augroup :END)
  )

(defn init []
  (init-mappings!))
