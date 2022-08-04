local _2afile_2a = "fnl/jump-to-clj-test/main.fnl"
local _2amodule_name_2a = "jump-to-clj-test.main"
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
local function bind(mode)
end
_2amodule_2a["bind"] = bind
local function on_filetype()
  return nvim.echo("mm on-filetype")
end
_2amodule_2a["on-filetype"] = on_filetype
local function init_mappings_21()
  nvim.ex.augroup("jump_to_clj_test_init_filetypes")
  nvim.ex.autocmd_()
  nvim.ex.autocmd("FileType", str.join(",", {"clojure"}), bridge["viml->lua"]("jump-to-clj-test.main", "on-filetype", {}))
  return nvim.ex.augroup("END")
end
_2amodule_2a["init-mappings!"] = init_mappings_21
local function init()
  return init_mappings_21()
end
_2amodule_2a["init"] = init
return _2amodule_2a