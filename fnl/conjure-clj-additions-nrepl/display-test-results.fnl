(module conjure-clj-additions-nrepl.display-test-results
  {autoload {str conjure.aniseed.string
             a conjure.aniseed.core}})

;(comment (def test-result {:utils.my-test {:qwe-test [{:type "pass"}
;                                                      {:actual "[:hi :a]"
;                                                       :context "should fail the tests"
;                                                       :diffs {1 {1 "[:hi :a]"
;                                                                  2 {1 "nil"
;                                                                     2 "[:hi :a]"}
;                                                                  }}
;                                                       :expected "[]"
;                                                       :file "form-init12588513328164867180.clj"
;                                                       :index 0
;                                                       :line 33
;                                                       :message ""
;                                                       :ns "util.url-test-one"
;                                                       :type "fail"
;                                                       :var "qweqwe-test"}
;                                                      {:actual "[:hi :a]"
;                                                       :context "should fail the tests"
;                                                       :diffs {1 {1 "[:hi :a]"
;                                                                  2 {1 "nil"
;                                                                     2 "[:hi :a]"}
;                                                                  }}
;                                                       :expected "[]"
;                                                       :file "form-init12588513328164867180.clj"
;                                                       :index 0
;                                                       :line 39
;                                                       :message ""
;                                                       :ns "util.url-test-two"
;                                                       :type "fail"
;                                                       :var "qweqwe-test"}]}}))

(defn iter-to-arr [iter]
  (accumulate [arr {}
               i iter]
    (a.concat arr [i])))
(comment (iter-to-arr (string.gmatch "hhhiahihihahihihiaa" "[^a]+")))

(defn str-split [s char]
  (iter-to-arr (string.gmatch s (.. "[^" char "]+"))))
(comment (str-split "hello" "l"))
(comment (str-split "hel\nl\no" "\n"))

(defn prefix-with-title [title strings]
  (if (= 0 (a.count strings))
    []
    (let [header (.. title (a.first strings))
          prefix (string.gsub title "." " ")]
      (a.concat [header]
                (a.map (fn [item]
                         (.. prefix item))
                       (a.rest strings))))))
(comment (prefix-with-title "hello" []))
(comment (prefix-with-title "hello" ["a" "b" "c"]))

(defn pprint-str [title data]
  (prefix-with-title title
                     (-> (a.str data)
                         (string.gsub "[\r\n]\"" "\"")
                         (str-split "\n"))))
(comment (pprint-str "hello: " test-result))

(defn display-result [text suite-result get-in-keys]
  (let [result (a.get-in suite-result get-in-keys)]
    (when (not (= 0 (a.count result)))
      (pprint-str (.. text " ") result))))

(defn display-loc [ns suite-sym line]
  (.. ns "/" suite-sym (if line
                         (.. ":" line)
                         "")))

(defn display-assertion-text [text]
  (if (= 0 (a.count text))
    ""
    (.. "\"" text "\" ")))

(defn display-suite-sym [result-type ns suite-sym line text]
  (.. result-type
      " "
      (display-loc ns suite-sym line)))

(defn display-suite-result [test-index suite-result]
  (let [ns (a.get suite-result :ns)
        suite-sym (a.get suite-result :var)]
    (a.concat
      [""
       (.. (a.str test-index) ". "
           (display-suite-sym (a.get suite-result :type)
                              ns
                              suite-sym
                              (a.get suite-result :line)
                              (a.get suite-result :context)))]
      [(.. "  " (display-assertion-text (a.get suite-result :context)))]
      (display-result "  Expected:" suite-result [:expected])
      (display-result "  Actual:" suite-result [:actual])
      (display-result "  Diff: -" suite-result [:diffs 1 2 2])
      (display-result "        +" suite-result [:diffs 1 2 1])
      (display-result "  Error:" suite-result [:error]))))
(comment (display-suite-result 99 (a.second (a.get-in test-result [:utils.my-test :qwe-test]))))

(defn pass? [suite-result]
  (= "pass" (a.get suite-result :type)))
(comment (pass? (a.first (a.get-in test-result [:utils.my-test :qwe-test])))0)

(defn display-suite-header [suite-symbol]
  (.. "  Suite: " suite-symbol))
(comment (display-suite-header "qwe-test"))

(defn display-ns-header [ns]
  (.. "  Namespace: " ns))
(comment (display-ns-header :utils.my-test))

(defn unwrap-suite-results [suite-results]
  (a.reduce (fn [res suite-result]
              (if (pass? suite-result)
                res
                (a.concat res
                          [suite-result])))
            []
            suite-results))

(defn unwrap-ns-result [ns-result]
  (a.reduce (fn [res suite-symbol]
              (a.concat res
                        (unwrap-suite-results (a.get ns-result suite-symbol))))
            []
            (a.keys ns-result)))

(defn unwrap [test-result]
  (->> (a.keys test-result)
       (a.reduce
         (fn [unwrapped ns]
           (a.concat unwrapped
                     (unwrap-ns-result (a.get test-result ns))))
         [])))
(comment (unwrap test-result))

(defn unwrapped-results->to-lines [unwrapped-results]
  (->> unwrapped-results
       (a.map-indexed (fn [iv] ; it sends tuple, not two args
                        (let [i (a.first iv)
                              v (a.second iv)]
                          (display-suite-result i v))))
       (a.mapcat a.identity)))

(defn to-lines [test-result]
  (->> test-result
       unwrap
       unwrapped-results->to-lines))
(comment (to-lines test-result))

(defn first-value [map]
  (->> (a.first (a.keys map))
       (a.get map)))
(comment (first-value (first-value test-result)))

(defn unwrapped-results->nth-test [unwrapped-results n]
  (let [nth-error (a.get unwrapped-results n)]
    (when nth-error
      (let [namespace (a.get nth-error :ns)
            line (a.get nth-error :line)]
        {:namespace namespace
         :failed-line line}))))
(comment (unwrapped-results->nth-test (unwrap test-result) 1))
(comment (unwrapped-results->nth-test (unwrap test-result) 2))

(defn first-failing-test [test-result]
  (unwrapped-results->nth-test (unwrap test-result) 1))
(comment (first-failing-test test-result))
