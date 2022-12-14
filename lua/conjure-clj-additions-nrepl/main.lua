local _2afile_2a = "fnl/conjure-clj-additions-nrepl/main.fnl"
local _2amodule_name_2a = "conjure-clj-additions-nrepl.main"
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
local bridge, fns, load_util, nvim, str = require("conjure.bridge"), require("conjure-clj-additions-nrepl.additional-fns"), require("conjure-clj-additions-nrepl.load-util"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string")
do end (_2amodule_locals_2a)["bridge"] = bridge
_2amodule_locals_2a["fns"] = fns
_2amodule_locals_2a["load-util"] = load_util
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
local function provide_fn_21(fn_name, ns, f)
  return nvim.ex.command_(("-range " .. fn_name), bridge["viml->lua"](ns, f, {}))
end
_2amodule_2a["provide-fn!"] = provide_fn_21
local function load_test_middleware_21()
  return load_util["try-load!"]("clojure", 10, fns["nrepl-middleware-present?"], fns["load-test-middleware!"])
end
_2amodule_2a["load-test-middleware!"] = load_test_middleware_21
local function on_filetype()
  provide_fn_21("CcaNsJumpToAlternate", "conjure-clj-additions-nrepl.additional-fns", "jump-to-alternate-ns!")
  provide_fn_21("CcaNreplLoadTestMiddleware", "conjure-clj-additions-nrepl.main", "load-test-middleware!")
  provide_fn_21("CcaNreplRunTestsInTestNs", "conjure-clj-additions-nrepl.additional-fns", "nrepl-middleware-run-test-ns-tests!")
  provide_fn_21("CcaNreplRunCurrentTest", "conjure-clj-additions-nrepl.additional-fns", "nrepl-run-current-test!")
  provide_fn_21("CcaNreplJumpToFailingCljTest", "conjure-clj-additions-nrepl.additional-fns", "nrepl-jump-to-nth-failing!")
  provide_fn_21("CcaNsRemove", "conjure-clj-additions-nrepl.additional-fns", "remove-ns!")
  provide_fn_21("CcaNsCleanup", "conjure-clj-additions-nrepl.additional-fns", "cleanup-ns!")
  provide_fn_21("CcaFormBench", "conjure-clj-additions-nrepl.additional-fns", "criterium-quick-bench!")
  provide_fn_21("CcaFormClass", "conjure-clj-additions-nrepl.additional-fns", "clj-java-decompile-class!")
  provide_fn_21("CcaFormDisasssemble", "conjure-clj-additions-nrepl.additional-fns", "clj-java-disasm-class!")
  provide_fn_21("CcaFormFlame", "conjure-clj-additions-nrepl.additional-fns", "clj-async-profile!")
  provide_fn_21("CcaFormFlameResults", "conjure-clj-additions-nrepl.additional-fns", "clj-async-profile-open-result-dir!")
  return load_test_middleware_21()
end
_2amodule_2a["on-filetype"] = on_filetype
local function init_mappings_21()
  nvim.ex.augroup("jump_to_clj_test_init_filetypes")
  nvim.ex.autocmd_()
  nvim.ex.autocmd("FileType", str.join(",", {"clojure"}), bridge["viml->lua"]("conjure-clj-additions-nrepl.main", "on-filetype", {}))
  return nvim.ex.augroup("END")
end
_2amodule_2a["init-mappings!"] = init_mappings_21
local function init()
  return init_mappings_21()
end
_2amodule_2a["init"] = init
return _2amodule_2a