(module narrower.core
  {;; You can use Lua's regular require or Aniseed's autoload.
   require {;;xyz some.cool.tool.xyz
            ;; Fennel destructuring syntax works but defeats the point of autoload.
            ;; Because a lookup is instantly invoked which triggers autoload at
            ;; module load time instead of when you need it in your code.
            ;;{: some-fn} some-module
 ;           const narrower.const
            }

   ;; Autoload lazily loads the module when you try to use the module methods or values at runtime.
   autoload {
             ;;a aniseed.core
;;             n narrower.ns_filter
             nvim conjure.aniseed.nvim
             str conjure.aniseed.string
             client conjure.client
             fennel fennel
             buffer conjure.buffer
             a aniseed.core
             editor conjure.editor 
             ;; Shorthand syntax for requiring under the same name.
             ;;: packer
             }})

;;(defn set-clojure-mode! [buffer-name]
;;  (nvim.ex.augroup :conjure_school_filetype)
;;  (nvim.ex.autocmd_)
;;  (nvim.ex.autocmd (string.format "BufNewFile,BufRead %s setlocal filetype=clojure" buffer-name))
;;  (nvim.ex.augroup :END))
;;
;;(defn start-buffer! []
;;  (set-clojure-mode! const.buf-name)
;;  (nvim.ex.edit const.buf-name))
;;(comment (start-buffer!))
;;
;;(defn shake! []
;;  (nvim.ex.edit const.buf-name))
;;(comment (shake!))

(defn execution-separator? [line]
  (string.match line "; [-]+"))
(comment (execution-separator? "; ------------"))
(comment (execution-separator? "; ------------\n"))

(defn run-ns-tests-find-ns [line]
  ; run-ns-tests: core.core-test
  (let [found-namespace (string.match line "; run[-]ns[-]tests: ([^\n]+)")]
    (when found-namespace
      {:namespace found-namespace})))
(comment (run-ns-tests-find-ns "; run-ns-tests: core.core-test\n"))
(comment (run-ns-tests-find-ns "; run-current-test: partial-test\n"))
(comment (run-ns-tests-find-ns "; hi: partial-test\n"))

(defn run-current-test-find-suite-name [failure-line]
  ; run-current-test: partial-test
  (let [found-suite-name (-> failure-line 
                             (string.match "; FAIL in [(]([^ ]+)[)].*")) ]
    (or (when found-suite-name
          {:suite-name found-suite-name}))))
(comment (run-current-test-find-suite-name "; FAIL in (my-test) (form-init3584826820959655573.clj:1664)\n"))

(defn failure-file-line [failure-line]
  (let [found-line (-> failure-line 
                       (string.match "; FAIL in [^ ]+ [^:]+:([0-9]+)")
                       tonumber)]
    (when found-line
      {:failed-line found-line})))
(comment (failure-file-line "; FAIL in (my-test) (form-init3584826820959655573.clj:1664)\n"))
(comment (failure-file-line "; FAIL in (my-test) (form-init3584826820959655573.clj)\n"))

(defn str-replace [txt find replacement]
  (->> (string.gsub txt find replacement)
       (pick-values 1)))
(comment (str-replace "txt" "x" "u"))
(comment (str-replace "{:test 6, :pass 19, :fail 0, :error 0, :type :summary}" "," " "))

(defn parse-obj [line]
  (var output nil)
  (pcall #(let [form (-> line 
                         (str-replace "," "")
                         fennel.eval)]
            (set output form)))
  output)
(comment (parse-obj "{:res :ok :id 1}"))
(comment (parse-obj "{:res :something-else :id 1}"))
(comment (parse-obj "{:res NOPE :ok :id 1}"))
(comment (parse-obj ":hello"))
(comment (fennel.eval (str-replace "{:test 6 :pass 19 :fail 0 :error 0 :type :summary}" "," " ")))
(comment (parse-obj "{:test 6, :pass 19, :fail 0, :error 0, :type :summary}"))

(defn drop-until-match [s match-str match-str-drop-len]
  (let [index (string.find s match-str)]
    (when index
      (string.sub s (+ index match-str-drop-len)))))
(comment (drop-until-match ";; aa{:res :ok :id 1}\n" "aa{" 2))
(comment (drop-until-match ";; aa{:res :ok :id 1}\n" "aa{" 1))

(defn parse-test-summary [line]
  ;; {:test 6, :pass 19, :fail 0, :error 0, :type :summary}
  (let [parsed (-> line
                   ;;(drop-until-match ";; " 2)
                   parse-obj)]
    (when (= :summary (a.get parsed :type))
      parsed)))
(comment (parse-test-summary "{:test 6, :pass 19, :fail 0, :error 0, :type :summary}\n"))
(comment (parse-test-summary "{:test 6, :pass 19, :fail 0, :error 0, :type :not-summary}\n"))
(comment (parse-test-summary "hi"))

(defn conjure-log-buf-name []
  ;; straight up copied from:
  ;; https://github.com/Olical/conjure/blob/2c42367fc301f3b38d1f25a68016eec59b834c1a/fnl/conjure/log.fnl#L32
  (str.join ["conjure-log-" (nvim.fn.getpid) (client.get :buf-suffix)]))

(defn- upsert-buf [buf-name]
  (buffer.upsert-hidden buf-name))

(defn empty? [li]
  (= 0 (length li)))
(comment (empty? []))
(comment (empty? [:hi]))

(defn chunk-by-header [f li]
  (let [out (a.reduce (fn [out item]
                        (let [current-group (a.get out :current-group)
                              output (a.get out :output)]
                          (if (f item)
                            (do 
                              (when (not (empty? current-group))
                                (table.insert output current-group))
                              (a.assoc out :current-group [item]))
                            (do 
                              (table.insert current-group item)
                              out))))
                      {:output []
                       :current-group []}
                      li)]
    (if (empty? (a.get out :current-group))
      (a.get out :output)
      (do
        (table.insert (a.get out :output)
                      (a.get out :current-group))
        (a.get out :output)))))
(comment (chunk-by-header (fn [item] (= item 2)) [1 2 3 4 5 6 7 2 8 9 2 0 2]))
(comment (chunk-by-header (fn [item] (= item 2)) [1 2 3 4 5 6 7 2 8 9 2 0]))
(comment (chunk-by-header (fn [item] (= item 2)) [2 3 2 5]))
(comment (chunk-by-header (fn [item] (= item 2)) [2 2]))

(defn to-chunks [lines]
  (chunk-by-header #(execution-separator? $1) lines))

(defn conjure-log-buf-content! []
  (-> (conjure-log-buf-name)
      upsert-buf 
      (vim.api.nvim_buf_get_lines 0 -1 true)))
(comment (conjure-log-buf-content!))

(defn filter-test-outputs [lines]
  (->> lines 
       to-chunks
       (a.map (fn [chunk] 
                (a.update chunk
                          (length chunk) 
                          (fn [last-chunk-line] 
                            (or (parse-test-summary last-chunk-line)
                                false)))
                chunk))
       (a.filter (fn [chunk] (a.last chunk)))
       a.last))
(comment (filter-test-outputs (conjure-log-buf-content!)))
(comment (def single-testsuite 
           ["; --------------------------------------------------------------------------------"
            "; run-current-test: testsuite-test"
            "; --------------------------------------------------------------------------------"
            "; run-current-test: testsuite-test"
            ";"
            "; FAIL in (partial-refunds-test) (form-init3584826820959655573.clj:124)"
            ";"
            "; Ran 6 tests containing 19 assertions."
            "; 1 failures, 0 errors."
            "{:test 6, :pass 18, :fail 1, :error 0, :type :summary}"]))
(comment (def namespace-testsuite 
           ["; --------------------------------------------------------------------------------"
            "; run-ns-tests: core.core-test"
            ";" 
            "; Testing core.core-test"
            ";" 
            "; FAIL in (partial-refunds-test) (form-init2746081655060792820.clj:1664)"
            ";"
            "; Ran 6 tests containing 19 assertions."
            "; 1 failures, 0 errors."
            "{:test 6, :pass 18, :fail 1, :error 0, :type :summary}"]))
(comment (filter-test-outputs single-testsuite))
(comment (filter-test-outputs namespace-testsuite))

(defn first-error-jump [test-result-chunk]
  (let [output (->> test-result-chunk
                    (a.map (fn [line]
                             (if (= "string" (type line))
                               (a.merge (run-current-test-find-suite-name line)
                                        (run-ns-tests-find-ns line)
                                        (failure-file-line line))
                               nil)))
                    (a.reduce a.merge {}))]
    (when (not (a.empty? output))
      output)))
(comment (first-error-jump (filter-test-outputs namespace-testsuite)))
(comment (first-error-jump (filter-test-outputs single-testsuite)))
(comment (first-error-jump (filter-test-outputs (conjure-log-buf-content!))))

(defn ns->filename [ns-name]
  (-> ns-name
      (string.gsub "-" "_")
      (string.gsub "[.]" "/")
      (.. ".clj")))
(comment (ns->filename "core.core-test"))
(comment (ns->filename "core.co-----re-tes-t"))

(defn buffer-details! [buf-id]
  {:buffer-id buf-id :buffer-name (nvim.buf_get_name buf-id)})

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
(defn find-buffer-to-jump! []
  (let [findings (first-error-jump (filter-test-outputs (conjure-log-buf-content!)))
        failing-namespace (a.get findings :namespace)
        failing-line (a.get findings :failed-line)]
    findings
    (if failing-namespace
      (a.merge (find-matching-buffer failing-namespace (get-buffers!)) findings)
      (when failing-line
        ;; TODO: could be nice to check it it's a test buffer
        (a.merge (get-current-buffer!) findings)))))
(comment (find-buffer-to-jump!))

;; vim commands https://github.com/norcalli/nvim.lua
;;vim.api.nvim_command("w")
;;(comment (editor.go-to "core.core-test" 14 0))
;;(comment (vim.api.nvim_command "exe w"))
(defn go-to-line! [buffer-name line]
  (editor.go-to buffer-name line 1))
(comment (go-to-line! (nvim.buf_get_name (nvim.buf.nr)) 249))

(defn go-to-first-readable-char! [buffer-id]
  ;;(nvim_buf_call) ;; not sure how to use this
  (vim.api.nvim_command "call search('[^ \t]')"))

(defn jump! [buffer-and-line-info]
  (let [buffer-id (a.get buffer-and-line-info :buffer-id)
        buffer-name (a.get buffer-and-line-info :buffer-name)
        failed-line (a.get buffer-and-line-info :failed-line)]
    (go-to-line! buffer-name failed-line)
    (go-to-first-readable-char! buffer-id)))
(comment (jump! {:buffer-id 26
                 :buffer-name "/home/martin/.config/nvim/fnl/narrower/core/core_test.clj"
                 :failed-line 10
                 :namespace "core.core-test"
                 :suite-name "partial-refunds-test"}))
(comment (jump! {:buffer-id 1
                 :buffer-name "/home/martin/.config/nvim/fnl/narrower/core.fnl"
                 :failed-line 270
                 :namespace "core.core-test"
                 :suite-name "partial-refunds-test"}))

(defn jump-to-last-failing-test! []
  (let [to-jump (find-buffer-to-jump!)]
    (if to-jump 
      (jump! to-jump)
      (nvim.echo "No tests to jump to"))))
(comment (jump-to-last-failing-test!))

