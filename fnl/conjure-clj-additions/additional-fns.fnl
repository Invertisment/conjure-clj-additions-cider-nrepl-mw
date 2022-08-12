(module conjure-clj-additions.additional-fns
  {autoload {text conjure.text
             extract conjure.extract
             str conjure.aniseed.string
             nrepl-action conjure.client.clojure.nrepl.action
             eval conjure.eval
             a conjure.aniseed.core
             server conjure.client.clojure.nrepl.server
             log conjure.log
             state conjure.client.clojure.nrepl.state
             display conjure-clj-additions.display-test-results
             jump conjure-clj-additions.jump
             nvim conjure.aniseed.nvim
             own-state conjure-clj-additions.state
             }})

(defn get-current-ns! []
  (extract.context))

(defn to-test-ns-name [current-ns]
  (if (text.ends-with current-ns "-test")
    current-ns
    (.. current-ns "-test")))

(defn get-test-ns-name! []
  (to-test-ns-name (get-current-ns!)))

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

;; https://github.com/Olical/conjure/blob/2e7f449d06753f2996e186954e96afc60edd5862/fnl/conjure/client/clojure/nrepl/server.fnl#L213
(defn- capture-describe! []
  (server.send
    {:op :describe}
    (fn [msg]
      (a.assoc (state.get :conn) :describe msg))))

;; https://github.com/Olical/conjure/blob/2e7f449d06753f2996e186954e96afc60edd5862/fnl/conjure/client/clojure/nrepl/server.fnl#L213
(defn nrepl-middleware-present? []
  (own-state.get-nrepl-test-middleware-present))

(defn load-test-middleware! []
  (server.with-conn-and-ops-or-warn
    [:add-middleware]
    (fn [conn ops]
      (print "before add-middleware")
      (server.send
        {:op :add-middleware
         :session conn.session
         :middleware ["cider.nrepl/wrap-test"]}
        (fn [_add-middleware-result]
          (print (.. "_add-middleware-result"
                     (str.join "," (a.keys _add-middleware-result))))
          (own-state.put-nrepl-test-middleware-present! true)
          ;; Copied from Conjure's internals.
          ;; This saves the `wrap-test` middleware so that with-conn-and-ops-or-warn would work
          (capture-describe!))))))

(defn- put-first-failed-result! [results]
  (own-state.put-first-failing-test-jump-loc!
    (let [first-failing (display.first-failing-test results)]
      (when first-failing
        (jump.find-buffer-to-jump! first-failing))
      ;jump.jump-to-buffer-and-line!
      ; (->> (jump.find-buffer-to-jump! first-failing)
      ;      a.vals
      ;      (str.join ",")
      ;      print)
      )))

(defn nrepl-test! [test-selector]
  (server.with-conn-and-ops-or-warn
    [:test :test-var-query]
    (fn [conn ops]
      (server.send
        (a.assoc test-selector :session conn.session)
        (fn [response]
          (let [results (a.get response :results)]
            (when results
              (put-first-failed-result! results)
              (log.append (display.to-lines results) {:break? true}))))))))

(defn nrepl-middleware-run-test-ns-tests! []
  (nrepl-test!
    {:op :test-var-query
     :var-query {:ns-query {:exactly [(get-test-ns-name!)]}}}))

(defn run-test-ns-tests! []
  (let [current-ns (get-current-ns!)]
    (if (text.ends-with current-ns "-test")
      (nrepl-action.run-current-ns-tests)
      (nrepl-action.run-alternate-ns-tests))))

(defn nrepl-run-current-test! []
  (let [form (extract.form {:root? true})]
    (when form
      (let [test-ns (get-test-ns-name!)
            test-name (nrepl-action.extract-test-name-from-form form.content)]
        (when test-name
          (nrepl-test!
            {:op :test-var-query
             :var-query {:ns-query {:exactly [test-ns]}
                         :exactly [(.. test-ns "/" test-name)]}}))))))

(defn nrepl-jump-to-first-failing! []
  (jump.jump-to-buffer-and-line!
    (own-state.get-first-failing-test-jump-loc)))

(defn jump-to-first-failing! []
  (jump.jump-to-last-failing-test!))

;(defn retest! []
;  (server.with-conn-and-ops-or-warn
;    [:add-middleware :describe]
;    (fn [conn ops]
;      (print (server.send
;               {:op :add-middleware
;                :session conn.session
;                :middleware ["cider.nrepl/wrap-test"]
;                ;:ns opts.context
;                }
;               (fn [add-middleware-result]
;                 ;;(print (.. "add-middleware res: " (str.join "," (a.keys add-middleware-result))))
;                 (server.send
;                   {:op :describe
;                    :session conn.session}
;                   (fn [describe-result]
;                     (print (.. "describe res: " (str.join "," (a.keys (a.get-in describe-result [:ops])))))))
;                 )))))
;  ; (print (.. "describe res: " (str.join "," (a.keys (a.get-in result [:status])))))
;  ; (a.get-in conn [:describe :ops])
;  )
