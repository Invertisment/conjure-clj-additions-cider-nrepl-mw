local _2afile_2a = "fnl/conjure-clj-additions/load-util.fnl"
local _2amodule_name_2a = "conjure-clj-additions.load-util"
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
local bridge, config, fns, nvim, str = require("conjure.bridge"), require("conjure.config"), require("conjure-clj-additions.additional-fns"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string")
do end (_2amodule_locals_2a)["bridge"] = bridge
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["fns"] = fns
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
local function try_load_21(match_filetype, retries, is_loaded_fn, try_load_fn)
  if (match_filetype == vim.bo.filetype) then
    local i = 0
    local skip = false
    local timer = vim.loop.new_timer()
    local function _1_()
      local function _2_()
        return try_load_fn()
      end
      vim.schedule_wrap(_2_)()
      if skip then
        return nil
      else
        if (is_loaded_fn() or not (i >= retries)) then
          skip = true
          return timer:close()
        else
          i = (1 + i)
          return nil
        end
      end
    end
    return timer:start(500, 100, _1_)
  else
    return nil
  end
end
_2amodule_2a["try-load!"] = try_load_21
return _2amodule_2a