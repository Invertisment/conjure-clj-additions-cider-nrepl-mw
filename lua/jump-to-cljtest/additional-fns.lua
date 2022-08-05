local _2afile_2a = "fnl/jump-to-cljtest/additional-fns.fnl"
local _2amodule_name_2a = "jump-to-cljtest.additional-fns"
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
local autoload = (require("jump-to-cljtest.aniseed.autoload")).autoload
local extract, nrepl_action, text = autoload("conjure.extract"), autoload("conjure.client.clojure.nrepl.action"), autoload("conjure.text")
do end (_2amodule_locals_2a)["extract"] = extract
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
return _2amodule_2a