local _2afile_2a = "fnl/conjure-additions/main.fnl"
local _2amodule_name_2a = "conjure-additions.main"
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
local bridge, config, nvim, str = require("conjure.bridge"), require("conjure.config"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string")
do end (_2amodule_locals_2a)["bridge"] = bridge
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
local function provide_fn_21(fn_name, ns, f)
  return nvim.ex.command_(("-range " .. fn_name), bridge["viml->lua"](ns, f, {}))
end
_2amodule_2a["provide-fn!"] = provide_fn_21
local function bind_21(mode, keystroke, fn_name, ns, f)
  provide_fn_21(fn_name, ns, f)
  return nvim.buf_set_keymap(0, mode, keystroke, (":" .. fn_name .. "<cr>"), {silent = true, noremap = true})
end
_2amodule_2a["bind!"] = bind_21
local function on_filetype()
  bind_21("n", "<localleader>tf", "JumpToFirstCljTest", "conjure-additions.jump", "jump-to-last-failing-test!")
  return provide_fn_21("JumpToFirstCljTestRunTestNsTests", "conjure-additions.additional-fns", "run-test-ns-tests!")
end
_2amodule_2a["on-filetype"] = on_filetype
local function init_mappings_21()
  nvim.ex.augroup("jump_to_clj_test_init_filetypes")
  nvim.ex.autocmd_()
  nvim.ex.autocmd("FileType", str.join(",", {"clojure"}), bridge["viml->lua"]("conjure-additions.main", "on-filetype", {}))
  return nvim.ex.augroup("END")
end
_2amodule_2a["init-mappings!"] = init_mappings_21
local function init()
  return init_mappings_21()
end
_2amodule_2a["init"] = init
return _2amodule_2a