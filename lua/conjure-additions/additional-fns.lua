local _2afile_2a = "fnl/conjure-additions/additional-fns.fnl"
local _2amodule_name_2a = "conjure-additions.additional-fns"
local _2amodule_2a
do
  package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("conjure-additions.aniseed.autoload")).autoload
local a, action, extract, nrepl_action, text = autoload("conjure.aniseed.core"), autoload("conjure.client.clojure.nrepl.action"), autoload("conjure.extract"), autoload("conjure.client.clojure.nrepl.action"), autoload("conjure.text")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["action"] = action
_2amodule_locals_2a["extract"] = extract
_2amodule_locals_2a["nrepl-action"] = nrepl_action
_2amodule_locals_2a["text"] = text
local function run_test_ns_tests_21()
  local current_ns = extract.context()
  if text["ends-with"](current_ns, "-test") then
    return nrepl_action["run-current-ns-tests"]()
  else
    return nrepl_action["run-alternate-ns-tests"]()
  end
end
_2amodule_2a["run-test-ns-tests!"] = run_test_ns_tests_21
local function remove_ns_21()
  return action["eval-str"]("(remove-ns (symbol (str *ns*)))")
end
_2amodule_2a["remove-ns!"] = remove_ns_21
local function cleanup_ns_21(opts)
  return action["eval-str"](("((fn clenaup-ns [ns-sym]" .. "  (when-let [ns (find-ns ns-sym)]" .. "    (run! #(try (ns-unalias ns %) (catch Throwable _)) (keys (ns-aliases ns)))" .. "    (run! #(try (ns-unmap ns %)   (catch Throwable _)) (keys (ns-interns ns)))" .. "    (->> (ns-refers ns)" .. "         (remove (fn [[_ v]] (.startsWith (str v) \"#'clojure.core/\")))" .. "         (map key)" .. "         (run! #(try (ns-unmap ns %) (catch Throwable _))))))" .. "   (symbol (str *ns*)))"))
end
_2amodule_2a["cleanup-ns!"] = cleanup_ns_21
return _2amodule_2a