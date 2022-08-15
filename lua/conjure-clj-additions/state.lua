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
__fnl_global__unwrapped_2dtest_2dresults = nil
local function put_unwrapped_test_results_21(value)
  __fnl_global__unwrapped_2dtest_2dresults = value
  return nil
end
_2amodule_2a["put-unwrapped-test-results!"] = put_unwrapped_test_results_21
local function get_unwrapped_test_results()
  return __fnl_global__unwrapped_2dtest_2dresults
end
_2amodule_2a["get-unwrapped-test-results"] = get_unwrapped_test_results
return _2amodule_2a