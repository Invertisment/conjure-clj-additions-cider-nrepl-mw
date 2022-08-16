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
  (a.get-in (state.get) [:conn :describe :ops :test-var-query]))

(defn load-test-middleware! []
  (server.with-conn-and-ops-or-warn
    [:add-middleware]
    (fn [conn ops]
      (server.send
        {:op :add-middleware
         :session conn.session
         :middleware ["cider.nrepl/wrap-test"]}
        (fn [_add-middleware-result]
          ;; Copied from Conjure's internals.
          ;; This saves the `wrap-test` middleware so that with-conn-and-ops-or-warn would work
          (capture-describe!))))))

(defn print-colored! [text-groups]
  (vim.api.nvim_echo text-groups false {}))

(defn txt-green  [text] [text "DiffAdded"])
(defn txt-red    [text] [text "DiffRemoved"])
(defn txt-yellow [text] [text "diffFile"])
(defn txt-normal [text] [text])

(defn join-prints [sep-chunk print-chunks]
  (->> print-chunks
       (a.mapcat (fn [chunk]
                   [chunk sep-chunk]))
       a.butlast))

(defn pos? [n]
  (> n 0))

(defn test-resp->text-groups [response descriptions]
  (->> descriptions
       (a.map (fn [desc]
                (let [[loc color-fn txt-postfix] desc
                      value (a.get-in response loc)]
                  (when (pos? value) (color-fn (.. value txt-postfix))))))
       (join-prints (txt-normal " "))))
;(comment (test-resp->text-groups {:resp {:fail 10 :error 2}}
;           [[[:resp :fail]  txt-yellow " errors"]
;            [[:resp :error] txt-red    " failures"]]))
;(comment (test-resp->text-groups
;           {:resp {:fail 0 :error 2}}
;           [[[:resp :fail]  txt-yellow " errors"]
;            [[:resp :error] txt-red    " failures"]]))
;(comment (test-resp->text-groups
;           {:resp {:fail 0 :error 2 :pass 5}}
;           [[[:resp :pass]  txt-green  " tests passed"]]))

(defn nrepl-test! [test-selector printable-info]
  (nvim.echo "...")
  (log.append [(.. "; Running tests in " printable-info)]
              {:break? true
               :suppress-hud? true})
  (server.with-conn-and-ops-or-warn
    [:test :test-var-query]
    (fn [conn ops]
      (server.send
        (a.assoc test-selector :session conn.session)
        (fn [response]
          (let [results (a.get response :results)]
            (let [unwrapped-results (display.unwrap results)]
              (when results
                (own-state.put-unwrapped-test-results! unwrapped-results)
                (let [lines (display.unwrapped-results->to-lines unwrapped-results)]
                  (if (= 0 (a.count lines))
                    (do
                      (print-colored! (test-resp->text-groups
                                        response
                                        [[[:summary :pass]  txt-green  " tests passed"]]))
                      (log.append ["; Tests passed"] {:suppress-hud? true}))
                    (do
                      (print-colored! (test-resp->text-groups
                                        response
                                        [[[:summary :error] txt-red    " errors"]
                                         [[:summary :fail]  txt-yellow " failures"]]))
                      (log.append lines {:break? true}))))))))))))

(defn nrepl-middleware-run-test-ns-tests! []
  (let [test-ns (get-test-ns-name!)]
    (nrepl-test!
      {:op :test-var-query
       :var-query {:ns-query {:exactly [test-ns]}}}
      test-ns)))

(defn run-test-ns-tests! []
  (let [current-ns (get-current-ns!)]
    (if (text.ends-with current-ns "-test")
      (nrepl-action.run-current-ns-tests)
      (nrepl-action.run-alternate-ns-tests))))

(defn nrepl-run-current-test! []
  (let [form (extract.form {:root? true})]
    (when form
      (let [test-ns (get-test-ns-name!)
            test-name (nrepl-action.extract-test-name-from-form form.content)
            printable-info (.. test-ns "/" test-name)]
        (when test-name
          (nrepl-test!
            {:op :test-var-query
             :var-query {:ns-query {:exactly [test-ns]}
                         :exactly [(.. test-ns "/" test-name)]}}
            printable-info))))))

(defn nrepl-jump-to-nth-failing! []
  (jump.jump-to-buffer-and-line!
    (display.unwrapped-results->nth-test
      (own-state.get-unwrapped-test-results)
      vim.v.count1)))

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
