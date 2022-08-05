(module conjure-additions.additional-fns
  { autoload {text conjure.text
              extract conjure.extract
              nrepl-action conjure.client.clojure.nrepl.action}})

(defn run-test-ns-tests! [] 
  (let [current-ns (extract.context)] 
    (if (text.ends-with current-ns "-test") 
      (nrepl-action.run-current-ns-tests)
      (nrepl-action.run-alternate-ns-tests)))) 
