local _2afile_2a = "fnl/conjure-clj-additions/state.fnl"
local _2amodule_name_2a = "conjure-clj-additions.state"
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
__fnl_global__first_2dfailing_2dtest_2dloc = nil
local function put_first_failing_test_jump_loc_21(jump_loc)
  __fnl_global__first_2dfailing_2dtest_2dloc = jump_loc
  return nil
end
_2amodule_2a["put-first-failing-test-jump-loc!"] = put_first_failing_test_jump_loc_21
local function get_first_failing_test_jump_loc()
  return __fnl_global__first_2dfailing_2dtest_2dloc
end
_2amodule_2a["get-first-failing-test-jump-loc"] = get_first_failing_test_jump_loc
__fnl_global__nrepl_2dtest_2dmiddleware_2dpresent = nil
local function put_nrepl_test_middleware_present_21(value)
  __fnl_global__nrepl_2dtest_2dmiddleware_2dpresent = value
  return nil
end
_2amodule_2a["put-nrepl-test-middleware-present!"] = put_nrepl_test_middleware_present_21
local function get_nrepl_test_middleware_present()
  return __fnl_global__nrepl_2dtest_2dmiddleware_2dpresent
end
_2amodule_2a["get-nrepl-test-middleware-present"] = get_nrepl_test_middleware_present
return _2amodule_2a