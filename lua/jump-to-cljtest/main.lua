local _2afile_2a = "fnl/jump-to-cljtest/main.fnl"
local _2amodule_name_2a = "jump-to-cljtest.main"
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
local bridge, nvim, str = require("conjure.bridge"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string")
do end (_2amodule_locals_2a)["bridge"] = bridge
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
local function bind_21(mode, keystroke, fn_name, ns, f)
  nvim.ex.command_(("-range " .. fn_name), bridge["viml->lua"](ns, f, {}))
  return nvim.buf_set_keymap(0, "n", keystroke, (":" .. fn_name .. "<cr>"), {silent = true, noremap = true})
end
_2amodule_2a["bind!"] = bind_21
local function on_filetype()
  return bind_21("n", "<localleader>tf", "JumpToFirstCljTest", "jump-to-cljtest.core", "jump-to-last-failing-test!")
end
_2amodule_2a["on-filetype"] = on_filetype
local function init_mappings_21()
  nvim.ex.augroup("jump_to_clj_test_init_filetypes")
  nvim.ex.autocmd_()
  nvim.ex.autocmd("FileType", str.join(",", {"clojure"}), bridge["viml->lua"]("jump-to-cljtest.main", "on-filetype", {}))
  return nvim.ex.augroup("END")
end
_2amodule_2a["init-mappings!"] = init_mappings_21
local function init()
  return init_mappings_21()
end
_2amodule_2a["init"] = init
return _2amodule_2a