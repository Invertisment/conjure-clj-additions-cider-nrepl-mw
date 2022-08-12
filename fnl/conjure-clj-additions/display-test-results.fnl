(module conjure-clj-additions.display-test-results
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
;                                                       :ns "util.url-test"
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

(defn display-result [text suite-result key]
  (let [result (a.get suite-result key)]
    (when (not (= 0 (a.count result)))
      (pprint-str (.. text " ") result))))

(defn display-suite-sym [result-type ns suite-sym line text]
  (if line
    ;(.. result-type " in " ns "/" suite-sym ":" line " (" text ")")
    ;(.. result-type " in " ns "/" suite-sym          " (" text ")")
    (.. ns "/" suite-sym ":" line " \"" text "\" ;;" result-type)
    (.. ns "/" suite-sym          " \"" text "\" ;;" result-type)))

(defn display-suite-result [ns suite-sym suite-result]
  (a.concat
    [""
     (display-suite-sym (a.get suite-result :type)
                        ns
                        suite-sym
                        (a.get suite-result :line)
                        (a.get suite-result :context))]
    (display-result "  Expected:" suite-result :expected)
    (display-result "  Actual:" suite-result :actual)
    (display-result "  Diff:" suite-result :diffs)
    (display-result "  Error:" suite-result :error)))
(comment (display-suite-result :ns :qwe-test (a.first (a.get-in test-result [:utils.my-test :qwe-test]))))

(defn pass? [suite-result]
  (= "pass" (a.get suite-result :type)))
(comment (pass? (a.first (a.get-in test-result [:utils.my-test :qwe-test])))0)

(defn display-suite-header [suite-symbol]
  (.. "  Suite: " suite-symbol))
(comment (display-suite-header "qwe-test"))

(defn display-suite-results [ns suite-symbol suite-results]
  (a.reduce (fn [res suite-result]
              (a.concat res
                        (if (pass? suite-result)
                          []
                          (display-suite-result ns suite-symbol suite-result))))
            []
            suite-results))
(comment (display-suite-results :ns :qwe-test (a.get-in test-result [:utils.my-test :qwe-test])))

(defn display-ns-header [ns]
  (.. "  Namespace: " ns))
(comment (display-ns-header :utils.my-test))

(defn display-ns-result [ns ns-result]
  (a.reduce (fn [res suite-symbol]
              (a.concat res
                        (display-suite-results ns suite-symbol (a.get-in ns-result [suite-symbol]))))
            []
            (a.keys ns-result)))
(comment (display-ns-result :utils.my-test (a.get-in test-result [:utils.my-test])))

(defn to-lines [test-result]
  (->> (a.keys test-result)
       (a.reduce
         (fn [lines ns]
           (a.concat lines
                     (display-ns-result ns (a.get-in test-result [ns]))))
         [])))
(comment (to-lines test-result))

(defn first-value [map]
  (->> (a.first (a.keys map))
       (a.get map)))
(comment (first-value (first-value test-result)))

(defn first-failing-test [test-result]
  (let [first-error (->> test-result
                         first-value
                         first-value
                         (a.filter (fn [res] (not (pass? res))))
                         a.first)]
    (when first-error
      (let [namespace (a.get first-error :ns)
            line (a.get first-error :line)]
        {:namespace namespace
         :failed-line line}))))
(comment (first-failing-test test-result))
