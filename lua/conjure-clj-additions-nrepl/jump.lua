local _2afile_2a = "fnl/conjure-clj-additions-nrepl/jump.fnl"
local _2amodule_name_2a = "conjure-clj-additions-nrepl.jump"
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
local autoload = (require("conjure-clj-additions-nrepl.aniseed.autoload")).autoload
local a, editor, fs, nvim = autoload("conjure-clj-additions-nrepl.aniseed.core"), autoload("conjure.editor"), autoload("conjure.fs"), autoload("conjure.aniseed.nvim")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["editor"] = editor
_2amodule_locals_2a["fs"] = fs
_2amodule_locals_2a["nvim"] = nvim
local function buffer_details_21(buf_id)
  return {["buffer-id"] = buf_id, ["buffer-name"] = nvim.buf_get_name(buf_id)}
end
_2amodule_2a["buffer-details!"] = buffer_details_21
--[[ (nvim.buf_get_name 0) ]]--
local function get_buffers_21()
  return a.map(buffer_details_21, vim.api.nvim_list_bufs())
end
_2amodule_2a["get-buffers!"] = get_buffers_21
--[[ (get-buffers!) ]]--
--[[ (def sample-buffers [{:buffer-id 1 :buffer-name "/home/_/.config/nvim/fnl/_/core.fnl"}
 {:buffer-id 3
  :buffer-name "/home/_/.config/nvim/fnl/_/conjure-log-683854.fnl"}
 {:buffer-id 131 :buffer-name "test/clj/core/core_test.clj"}
 {:buffer-id 13 :buffer-name "/home/_/.config/nvim/fnl/_/core.core-test"}]) ]]--
local function get_current_buffer_21()
  return buffer_details_21(nvim.buf.nr())
end
_2amodule_2a["get-current-buffer!"] = get_current_buffer_21
local function ns__3efilename(ns_name)
  return (string.gsub(string.gsub(ns_name, "-", "_"), "[.]", "/") .. ".clj")
end
_2amodule_2a["ns->filename"] = ns__3efilename
--[[ (ns->filename "core.core-test") ]]--
--[[ (ns->filename "core.co-----re-tes-t") ]]--
local function find_matching_buffer(expected_ns, buffers)
  local to_find = ns__3efilename(expected_ns)
  local function _1_(desc)
    local id = a.get(desc, "buffer-id")
    local name = a.get(desc, "buffer-name")
    return string.find(name, to_find)
  end
  return a.first(a.filter(_1_, buffers))
end
_2amodule_2a["find-matching-buffer"] = find_matching_buffer
--[[ (find-matching-buffer "core.core-test" sample-buffers) ]]--
--[[ (find-matching-buffer "core.core-test2" sample-buffers) ]]--
--[[ (find-matching-buffer "core.core-test" (get-buffers!)) ]]--
local function find_buffer_to_jump_21(buf_info)
  local failing_namespace = a.get(buf_info, "namespace")
  local failing_line = a.get(buf_info, "failed-line")
  if failing_namespace then
    local found = find_matching_buffer(failing_namespace, get_buffers_21())
    if found then
      return a.merge(found, buf_info)
    else
      return nil
    end
  else
    if failing_line then
      return a.merge(get_current_buffer_21(), buf_info)
    else
      return nil
    end
  end
end
_2amodule_2a["find-buffer-to-jump!"] = find_buffer_to_jump_21
local function edit_buffer_21(buffer_name)
  if a["string?"](buffer_name) then
    return nvim.ex.edit(fs["localise-path"](buffer_name))
  else
    return nil
  end
end
_2amodule_2a["edit-buffer!"] = edit_buffer_21
local function go_to_first_char_21()
  return vim.api.nvim_exec(":normal! _", false)
end
_2amodule_2a["go-to-first-char!"] = go_to_first_char_21
local function go_to_line_21(buffer_name, line)
  edit_buffer_21(buffer_name)
  editor["go-to"](buffer_name, line, 1)
  return go_to_first_char_21()
end
_2amodule_2a["go-to-line!"] = go_to_line_21
--[[ (go-to-line! (nvim.buf_get_name (nvim.buf.nr)) 249) ]]--
local function go_to_buffer_21(buffer_name, buffer_id)
  return edit_buffer_21(buffer_name)
end
_2amodule_2a["go-to-buffer!"] = go_to_buffer_21
local function jump_21(buffer_and_line_info)
  local failed_line = a.get(buffer_and_line_info, "failed-line")
  if failed_line then
    return go_to_line_21(a.get(buffer_and_line_info, "buffer-name"), failed_line)
  else
    return go_to_buffer_21(a.get(buffer_and_line_info, "buffer-name"), a.get(buffer_and_line_info, "buffer-id"))
  end
end
_2amodule_2a["jump!"] = jump_21
--[[ (jump! {:buffer-id 26
 :buffer-name "/home/user/.config/nvim/fnl/_/core/core_test.clj"
 :failed-line 10
 :namespace "core.core-test"
 :suite-name "my-failing-testsuite"}) ]]--
--[[ (jump! {:buffer-id 1
 :buffer-name "/home/user/.config/nvim/fnl/_/core.fnl"
 :failed-line 270
 :namespace "core.core-test"
 :suite-name "my-failing-testsuite"}) ]]--
local function jump_to_buffer_and_line_21(to_jump)
  if to_jump then
    return jump_21(to_jump)
  else
    return nvim.echo("Nothing to jump to")
  end
end
_2amodule_2a["jump-to-buffer-and-line!"] = jump_to_buffer_and_line_21
return _2amodule_2a