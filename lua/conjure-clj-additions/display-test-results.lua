local _2afile_2a = "fnl/conjure-clj-additions/display-test-results.fnl"
local _2amodule_name_2a = "conjure-clj-additions.display-test-results"
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
local autoload = (require("conjure-clj-additions.aniseed.autoload")).autoload
local a, str = autoload("conjure.aniseed.core"), autoload("conjure.aniseed.string")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["str"] = str
local function iter_to_arr(iter)
  local arr = {}
  for i in iter do
    arr = a.concat(arr, {i})
  end
  return arr
end
_2amodule_2a["iter-to-arr"] = iter_to_arr
--[[ (iter-to-arr (string.gmatch "hhhiahihihahihihiaa" "[^a]+")) ]]--
local function str_split(s, char)
  return iter_to_arr(string.gmatch(s, ("[^" .. char .. "]+")))
end
_2amodule_2a["str-split"] = str_split
--[[ (str-split "hello" "l") ]]--
--[[ (str-split "hel
l
o" "
") ]]--
local function prefix_with_title(title, strings)
  if (0 == a.count(strings)) then
    return {}
  else
    local header = (title .. a.first(strings))
    local prefix = string.gsub(title, ".", " ")
    local function _1_(item)
      return (prefix .. item)
    end
    return a.concat({header}, a.map(_1_, a.rest(strings)))
  end
end
_2amodule_2a["prefix-with-title"] = prefix_with_title
--[[ (prefix-with-title "hello" {}) ]]--
--[[ (prefix-with-title "hello" ["a" "b" "c"]) ]]--
local function pprint_str(title, data)
  return prefix_with_title(title, str_split(string.gsub(a.str(data), "[\13\n]\"", "\""), "\n"))
end
_2amodule_2a["pprint-str"] = pprint_str
--[[ (pprint-str "hello: " test-result) ]]--
local function display_result(text, suite_result, key)
  local result = a.get(suite_result, key)
  if not (0 == a.count(result)) then
    return pprint_str((text .. " "), result)
  else
    return nil
  end
end
_2amodule_2a["display-result"] = display_result
local function display_loc(ns, suite_sym, line)
  local function _4_()
    if line then
      return (":" .. line .. " ")
    else
      return ""
    end
  end
  return (ns .. "/" .. suite_sym .. _4_())
end
_2amodule_2a["display-loc"] = display_loc
local function display_assertion_text(text)
  if (0 == a.count(text)) then
    return ""
  elseif "\"" then
    return text
  else
    return "\" "
  end
end
_2amodule_2a["display-assertion-text"] = display_assertion_text
local function display_suite_sym(result_type, ns, suite_sym, line, text)
  if (0 == a.count(text)) then
  elseif "\"" then
  else
  end
  if line then
    return (display_loc(ns, suite_sym, line) .. display_assertion_text(text) .. result_type)
  else
    return nil
  end
end
_2amodule_2a["display-suite-sym"] = display_suite_sym
local function display_suite_result(test_index, suite_result)
  local ns = a.get(suite_result, "ns")
  local suite_sym = a.get(suite_result, "var")
  return a.concat({"", (a.str(test_index) .. ". " .. display_suite_sym(a.get(suite_result, "type"), ns, suite_sym, a.get(suite_result, "line"), a.get(suite_result, "context")))}, display_result("  Expected:", suite_result, "expected"), display_result("  Actual:", suite_result, "actual"), display_result("  Diff:", suite_result, "diffs"), display_result("  Error:", suite_result, "error"))
end
_2amodule_2a["display-suite-result"] = display_suite_result
--[[ (display-suite-result 99 (a.second (a.get-in test-result ["utils.my-test" "qwe-test"]))) ]]--
local function pass_3f(suite_result)
  return ("pass" == a.get(suite_result, "type"))
end
_2amodule_2a["pass?"] = pass_3f
--[[ (pass? (a.first (a.get-in test-result ["utils.my-test" "qwe-test"]))) 0 ]]--
local function display_suite_header(suite_symbol)
  return ("  Suite: " .. suite_symbol)
end
_2amodule_2a["display-suite-header"] = display_suite_header
--[[ (display-suite-header "qwe-test") ]]--
local function display_ns_header(ns)
  return ("  Namespace: " .. ns)
end
_2amodule_2a["display-ns-header"] = display_ns_header
--[[ (display-ns-header "utils.my-test") ]]--
local function unwrap_suite_results(suite_results)
  local function _8_(res, suite_result)
    if pass_3f(suite_result) then
      return res
    else
      return a.concat(res, {suite_result})
    end
  end
  return a.reduce(_8_, {}, suite_results)
end
_2amodule_2a["unwrap-suite-results"] = unwrap_suite_results
local function unwrap_ns_result(ns_result)
  local function _10_(res, suite_symbol)
    return a.concat(res, unwrap_suite_results(a.get(ns_result, suite_symbol)))
  end
  return a.reduce(_10_, {}, a.keys(ns_result))
end
_2amodule_2a["unwrap-ns-result"] = unwrap_ns_result
local function unwrap(test_result)
  local function _11_(unwrapped, ns)
    return a.concat(unwrapped, unwrap_ns_result(a.get(test_result, ns)))
  end
  return a.reduce(_11_, {}, a.keys(test_result))
end
_2amodule_2a["unwrap"] = unwrap
--[[ (unwrap test-result) ]]--
local function unwrapped_results__3eto_lines(unwrapped_results)
  local function _12_(iv)
    local i = a.first(iv)
    local v = a.second(iv)
    return display_suite_result(i, v)
  end
  return a.mapcat(a.identity, a["map-indexed"](_12_, unwrapped_results))
end
_2amodule_2a["unwrapped-results->to-lines"] = unwrapped_results__3eto_lines
local function to_lines(test_result)
  return unwrapped_results__3eto_lines(unwrap(test_result))
end
_2amodule_2a["to-lines"] = to_lines
--[[ (to-lines test-result) ]]--
local function first_value(map)
  return a.get(map, a.first(a.keys(map)))
end
_2amodule_2a["first-value"] = first_value
--[[ (first-value (first-value test-result)) ]]--
local function unwrapped_results__3enth_test(unwrapped_results, n)
  local nth_error = a.get(unwrapped_results, n)
  if nth_error then
    local namespace = a.get(nth_error, "ns")
    local line = a.get(nth_error, "line")
    return {namespace = namespace, ["failed-line"] = line}
  else
    return nil
  end
end
_2amodule_2a["unwrapped-results->nth-test"] = unwrapped_results__3enth_test
--[[ (unwrapped-results->nth-test (unwrap test-result) 1) ]]--
--[[ (unwrapped-results->nth-test (unwrap test-result) 2) ]]--
local function first_failing_test(test_result)
  return unwrapped_results__3enth_test(unwrap(test_result), 1)
end
_2amodule_2a["first-failing-test"] = first_failing_test
--[[ (first-failing-test test-result) ]]--
return _2amodule_2a