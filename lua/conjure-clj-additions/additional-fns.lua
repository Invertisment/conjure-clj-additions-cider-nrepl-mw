local _2afile_2a = "fnl/conjure-clj-additions/additional-fns.fnl"
local _2amodule_name_2a = "conjure-clj-additions.additional-fns"
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
local a, display, eval, extract, jump, log, nrepl_action, nvim, own_state, server, state, str, text = autoload("conjure.aniseed.core"), autoload("conjure-clj-additions.display-test-results"), autoload("conjure.eval"), autoload("conjure.extract"), autoload("conjure-clj-additions.jump"), autoload("conjure.log"), autoload("conjure.client.clojure.nrepl.action"), autoload("conjure.aniseed.nvim"), autoload("conjure-clj-additions.state"), autoload("conjure.client.clojure.nrepl.server"), autoload("conjure.client.clojure.nrepl.state"), autoload("conjure.aniseed.string"), autoload("conjure.text")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["display"] = display
_2amodule_locals_2a["eval"] = eval
_2amodule_locals_2a["extract"] = extract
_2amodule_locals_2a["jump"] = jump
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["nrepl-action"] = nrepl_action
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["own-state"] = own_state
_2amodule_locals_2a["server"] = server
_2amodule_locals_2a["state"] = state
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
local function get_current_ns_21()
  return extract.context()
end
_2amodule_2a["get-current-ns!"] = get_current_ns_21
local function to_test_ns_name(current_ns)
  if text["ends-with"](current_ns, "-test") then
    return current_ns
  else
    return (current_ns .. "-test")
  end
end
_2amodule_2a["to-test-ns-name"] = to_test_ns_name
local function get_test_ns_name_21()
  return to_test_ns_name(get_current_ns_21())
end
_2amodule_2a["get-test-ns-name!"] = get_test_ns_name_21
local function remove_ns_21()
  return eval.command("(remove-ns (symbol (str *ns*)))")
end
_2amodule_2a["remove-ns!"] = remove_ns_21
local function cleanup_ns_21()
  return eval.command(("((fn clenaup-ns [ns-sym]" .. "  (when-let [ns (find-ns ns-sym)]" .. "    (run! #(try (ns-unalias ns %) (catch Throwable _)) (keys (ns-aliases ns)))" .. "    (run! #(try (ns-unmap ns %)   (catch Throwable _)) (keys (ns-interns ns)))" .. "    (->> (ns-refers ns)" .. "         (remove (fn [[_ v]] (.startsWith (str v) \"#'clojure.core/\")))" .. "         (map key)" .. "         (run! #(try (ns-unmap ns %) (catch Throwable _))))))" .. "   (symbol (str *ns*)))"))
end
_2amodule_2a["cleanup-ns!"] = cleanup_ns_21
local function capture_describe_21()
  local function _2_(msg)
    return a.assoc(state.get("conn"), "describe", msg)
  end
  return server.send({op = "describe"}, _2_)
end
_2amodule_locals_2a["capture-describe!"] = capture_describe_21
local function nrepl_middleware_present_3f()
  return own_state["get-nrepl-test-middleware-present"]()
end
_2amodule_2a["nrepl-middleware-present?"] = nrepl_middleware_present_3f
local function load_test_middleware_21()
  local function _3_(conn, ops)
    print("before add-middleware")
    local function _4_(_add_middleware_result)
      print(("_add-middleware-result" .. str.join(",", a.keys(_add_middleware_result))))
      own_state["put-nrepl-test-middleware-present!"](true)
      return capture_describe_21()
    end
    return server.send({op = "add-middleware", session = conn.session, middleware = {"cider.nrepl/wrap-test"}}, _4_)
  end
  return server["with-conn-and-ops-or-warn"]({"add-middleware"}, _3_)
end
_2amodule_2a["load-test-middleware!"] = load_test_middleware_21
local function nrepl_test_21(test_selector)
  local function _5_(conn, ops)
    local function _6_(response)
      local results = a.get(response, "results")
      local unwrapped_results = display.unwrap(results)
      if results then
        own_state["put-unwrapped-test-results!"](unwrapped_results)
        return log.append(display["unwrapped-results->to-lines"](unwrapped_results), {["break?"] = true})
      else
        return nil
      end
    end
    return server.send(a.assoc(test_selector, "session", conn.session), _6_)
  end
  return server["with-conn-and-ops-or-warn"]({"test", "test-var-query"}, _5_)
end
_2amodule_2a["nrepl-test!"] = nrepl_test_21
local function nrepl_middleware_run_test_ns_tests_21()
  return nrepl_test_21({op = "test-var-query", ["var-query"] = {["ns-query"] = {exactly = {get_test_ns_name_21()}}}})
end
_2amodule_2a["nrepl-middleware-run-test-ns-tests!"] = nrepl_middleware_run_test_ns_tests_21
local function run_test_ns_tests_21()
  local current_ns = get_current_ns_21()
  if text["ends-with"](current_ns, "-test") then
    return nrepl_action["run-current-ns-tests"]()
  else
    return nrepl_action["run-alternate-ns-tests"]()
  end
end
_2amodule_2a["run-test-ns-tests!"] = run_test_ns_tests_21
local function nrepl_run_current_test_21()
  local form = extract.form({["root?"] = true})
  if form then
    local test_ns = get_test_ns_name_21()
    local test_name = nrepl_action["extract-test-name-from-form"](form.content)
    if test_name then
      return nrepl_test_21({op = "test-var-query", ["var-query"] = {["ns-query"] = {exactly = {test_ns}}, exactly = {(test_ns .. "/" .. test_name)}}})
    else
      return nil
    end
  else
    return nil
  end
end
_2amodule_2a["nrepl-run-current-test!"] = nrepl_run_current_test_21
local function nrepl_jump_to_nth_failing_21()
  return jump["jump-to-buffer-and-line!"](display["unwrapped-results->nth-test"](own_state["get-unwrapped-test-results"](), vim.v.count1))
end
_2amodule_2a["nrepl-jump-to-nth-failing!"] = nrepl_jump_to_nth_failing_21
local function jump_to_first_failing_21()
  return jump["jump-to-last-failing-test!"]()
end
_2amodule_2a["jump-to-first-failing!"] = jump_to_first_failing_21
return _2amodule_2a