(module conjure-clj-additions.additional-fns
  {autoload {text conjure.text
             extract conjure.extract
             nrepl-action conjure.client.clojure.nrepl.action
             eval conjure.eval
             a conjure.aniseed.core
             server conjure.client.clojure.nrepl.server}})

(defn run-test-ns-tests! []
  (let [current-ns (extract.context)]
    (if (text.ends-with current-ns "-test")
      (nrepl-action.run-current-ns-tests)
      (nrepl-action.run-alternate-ns-tests))))

(defn remove-ns! []
  (eval.command "(remove-ns (symbol (str *ns*)))"))

(defn cleanup-ns! []
  (eval.command
    (..
      ;; Cleanup a namespace
      ;; https://www.reddit.com/r/Clojure/comments/rq51mg/comment/hq9gfk6/?utm_source=reddit&utm_medium=web2x&context=3
      ;; https://github.com/seancorfield/vscode-clover-setup/blob/develop/config.cljs#L79-L89
      "((fn clenaup-ns [ns-sym]"
      "  (when-let [ns (find-ns ns-sym)]"
      "    (run! #(try (ns-unalias ns %) (catch Throwable _)) (keys (ns-aliases ns)))"
      "    (run! #(try (ns-unmap ns %)   (catch Throwable _)) (keys (ns-interns ns)))"
      "    (->> (ns-refers ns)"
      "         (remove (fn [[_ v]] (.startsWith (str v) \"#'clojure.core/\")))"
      "         (map key)"
      "         (run! #(try (ns-unmap ns %) (catch Throwable _))))))"
      "   (symbol (str *ns*)))")))

(defn print-last-test-result! []
  ;;(server.with-conn-and-ops-or-warn
  ;;  [:complete :completions]
  ;;  (fn [conn ops]
  ;;    (server.send
  ;;      (if))))
  )

(defn retest! []
  (server.with-conn-and-ops-or-warn
    [:retest]
    (fn [conn ops]
      (server.send
        {:op :retest
         :session conn.session
         :ns opts.context}))))
