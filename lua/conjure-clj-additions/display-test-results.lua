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
local function display_suite_sym(result_type, ns, suite_sym, line, text)
  if line then
    return (ns .. "/" .. suite_sym .. ":" .. line .. " \"" .. text .. "\" ;;" .. result_type)
  else
    return (ns .. "/" .. suite_sym .. " \"" .. text .. "\" ;;" .. result_type)
  end
end
_2amodule_2a["display-suite-sym"] = display_suite_sym
local function display_suite_result(ns, suite_sym, suite_result)
  return a.concat({"", display_suite_sym(a.get(suite_result, "type"), ns, suite_sym, a.get(suite_result, "line"), a.get(suite_result, "context"))}, display_result("  Expected:", suite_result, "expected"), display_result("  Actual:", suite_result, "actual"), display_result("  Diff:", suite_result, "diffs"), display_result("  Error:", suite_result, "error"))
end
_2amodule_2a["display-suite-result"] = display_suite_result
--[[ (display-suite-result "ns" "qwe-test" (a.first (a.get-in test-result ["utils.my-test" "qwe-test"]))) ]]--
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
local function display_suite_results(ns, suite_symbol, suite_results)
  local function _5_(res, suite_result)
    local function _6_()
      if pass_3f(suite_result) then
        return {}
      else
        return display_suite_result(ns, suite_symbol, suite_result)
      end
    end
    return a.concat(res, _6_())
  end
  return a.reduce(_5_, {}, suite_results)
end
_2amodule_2a["display-suite-results"] = display_suite_results
--[[ (display-suite-results "ns" "qwe-test" (a.get-in test-result ["utils.my-test" "qwe-test"])) ]]--
local function display_ns_header(ns)
  return ("  Namespace: " .. ns)
end
_2amodule_2a["display-ns-header"] = display_ns_header
--[[ (display-ns-header "utils.my-test") ]]--
local function display_ns_result(ns, ns_result)
  local function _7_(res, suite_symbol)
    return a.concat(res, display_suite_results(ns, suite_symbol, a["get-in"](ns_result, {suite_symbol})))
  end
  return a.reduce(_7_, {}, a.keys(ns_result))
end
_2amodule_2a["display-ns-result"] = display_ns_result
--[[ (display-ns-result "utils.my-test" (a.get-in test-result ["utils.my-test"])) ]]--
local function to_lines(test_result)
  local function _8_(lines, ns)
    return a.concat(lines, display_ns_result(ns, a["get-in"](test_result, {ns})))
  end
  return a.reduce(_8_, {}, a.keys(test_result))
end
_2amodule_2a["to-lines"] = to_lines
--[[ (to-lines test-result) ]]--
local function first_value(map)
  return a.get(map, a.first(a.keys(map)))
end
_2amodule_2a["first-value"] = first_value
--[[ (first-value (first-value test-result)) ]]--
local function first_failing_test(test_result)
  local first_error
  local function _9_(res)
    return not pass_3f(res)
  end
  first_error = a.first(a.filter(_9_, first_value(first_value(test_result))))
  if first_error then
    local namespace = a.get(first_error, "ns")
    local line = a.get(first_error, "line")
    return {namespace = namespace, ["failed-line"] = line}
  else
    return nil
  end
end
_2amodule_2a["first-failing-test"] = first_failing_test
--[[ (first-failing-test test-result) ]]--
return _2amodule_2a