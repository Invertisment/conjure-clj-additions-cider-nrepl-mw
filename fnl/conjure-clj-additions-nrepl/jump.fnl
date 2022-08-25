(module conjure-clj-additions-nrepl.jump
  {autoload {nvim conjure.aniseed.nvim
             a aniseed.core
             editor conjure.editor
             fs conjure.fs
             }})

(defn buffer-details! [buf-id]
  {:buffer-id buf-id :buffer-name (nvim.buf_get_name buf-id)})
(comment (nvim.buf_get_name 0))

(defn get-buffers! []
  (a.map buffer-details! (vim.api.nvim_list_bufs)))
(comment (get-buffers!))
(comment (def sample-buffers ;; not sure why but nested list fails here
           {1 {:buffer-id 1   :buffer-name "/home/_/.config/nvim/fnl/_/core.fnl"}
            2 {:buffer-id 3   :buffer-name "/home/_/.config/nvim/fnl/_/conjure-log-683854.fnl"}
            3 {:buffer-id 131 :buffer-name "test/clj/core/core_test.clj"}
            4 {:buffer-id 13  :buffer-name "/home/_/.config/nvim/fnl/_/core.core-test"}}))
(defn get-current-buffer! []
  (buffer-details! (nvim.buf.nr)))

(defn find-matching-buffer [expected-ns buffers]
  (let [to-find (ns->filename expected-ns)]
    (->> buffers
         (a.filter (fn [desc]
                     (let [id (a.get desc :buffer-id)
                           name (a.get desc :buffer-name)]
                       (string.find name to-find))))
         a.first)))
(comment (find-matching-buffer "core.core-test" sample-buffers))
(comment (find-matching-buffer "core.core-test2" sample-buffers))
(comment (find-matching-buffer "core.core-test" (get-buffers!)))

(defn find-buffer-to-jump! [buf-info]
  (let [failing-namespace (a.get buf-info :namespace)
        failing-line (a.get buf-info :failed-line)]
    (if failing-namespace
      (let [found (find-matching-buffer failing-namespace (get-buffers!))]
        (when found
          (a.merge found buf-info)))
      (when failing-line
        (a.merge (get-current-buffer!) buf-info)))))

(defn edit-buffer! [buffer-name]
  (when (a.string? buffer-name)
    (nvim.ex.edit (fs.localise-path buffer-name))))

(defn go-to-first-char! []
  (vim.api.nvim_exec ":normal! _" false))

(defn go-to-line! [buffer-name line]
  (edit-buffer! buffer-name)
  (editor.go-to buffer-name line 1)
  (go-to-first-char!))
(comment (go-to-line! (nvim.buf_get_name (nvim.buf.nr)) 249))

(defn go-to-buffer! [buffer-name buffer-id]
  (edit-buffer! buffer-name))

(defn jump! [buffer-and-line-info]
  (let [failed-line (a.get buffer-and-line-info :failed-line)]
    (if failed-line
      (go-to-line! (a.get buffer-and-line-info :buffer-name)
                   failed-line)
      (do
        (go-to-buffer! (a.get buffer-and-line-info :buffer-name)
                       (a.get buffer-and-line-info :buffer-id))))))
(comment (jump! {:buffer-id 26
                 :buffer-name "/home/user/.config/nvim/fnl/_/core/core_test.clj"
                 :failed-line 10
                 :namespace "core.core-test"
                 :suite-name "my-failing-testsuite"}))
(comment (jump! {:buffer-id 1
                 :buffer-name "/home/user/.config/nvim/fnl/_/core.fnl"
                 :failed-line 270
                 :namespace "core.core-test"
                 :suite-name "my-failing-testsuite"}))

(defn jump-to-buffer-and-line! [to-jump]
  (if to-jump
    (jump! to-jump)
    (nvim.echo "Nothing to jump to")))
