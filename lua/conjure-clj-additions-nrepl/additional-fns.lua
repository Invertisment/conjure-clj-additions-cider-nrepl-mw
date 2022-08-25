local _2afile_2a = "fnl/conjure-clj-additions-nrepl/additional-fns.fnl"
local _2amodule_name_2a = "conjure-clj-additions-nrepl.additional-fns"
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
local a, display, eval, extract, jump, log, nrepl_action, nvim, own_state, server, state, str, text = autoload("conjure.aniseed.core"), autoload("conjure-clj-additions-nrepl.display-test-results"), autoload("conjure.eval"), autoload("conjure.extract"), autoload("conjure-clj-additions-nrepl.jump"), autoload("conjure.log"), autoload("conjure.client.clojure.nrepl.action"), autoload("conjure.aniseed.nvim"), autoload("conjure-clj-additions-nrepl.state"), autoload("conjure.client.clojure.nrepl.server"), autoload("conjure.client.clojure.nrepl.state"), autoload("conjure.aniseed.string"), autoload("conjure.text")
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
local function get_alternate_ns_name_21()
  local current_ns = get_current_ns_21()
  if text["ends-with"](current_ns, "-test") then
    return string.sub(current_ns, 1, -6)
  else
    return (current_ns .. "-test")
  end
end
_2amodule_2a["get-alternate-ns-name!"] = get_alternate_ns_name_21
local function remove_ns_21()
  return eval.command("(remove-ns (symbol (str *ns*)))")
end
_2amodule_2a["remove-ns!"] = remove_ns_21
local function cleanup_ns_21()
  return eval.command(("((fn clenaup-ns [ns-sym]" .. "  (when-let [ns (find-ns ns-sym)]" .. "    (run! #(try (ns-unalias ns %) (catch Throwable _)) (keys (ns-aliases ns)))" .. "    (run! #(try (ns-unmap ns %)   (catch Throwable _)) (keys (ns-interns ns)))" .. "    (->> (ns-refers ns)" .. "         (remove (fn [[_ v]] (.startsWith (str v) \"#'clojure.core/\")))" .. "         (map key)" .. "         (run! #(try (ns-unmap ns %) (catch Throwable _))))))" .. "   (symbol (str *ns*)))"))
end
_2amodule_2a["cleanup-ns!"] = cleanup_ns_21
local function capture_describe_21()
  local function _3_(msg)
    return a.assoc(state.get("conn"), "describe", msg)
  end
  return server.send({op = "describe"}, _3_)
end
_2amodule_locals_2a["capture-describe!"] = capture_describe_21
local function nrepl_middleware_present_3f()
  return a["get-in"](state.get(), {"conn", "describe", "ops", "test-var-query"})
end
_2amodule_2a["nrepl-middleware-present?"] = nrepl_middleware_present_3f
local function load_test_middleware_21()
  local function _4_(conn, ops)
    local function _5_(_add_middleware_result)
      return capture_describe_21()
    end
    return server.send({op = "add-middleware", session = conn.session, middleware = {"cider.nrepl/wrap-test"}}, _5_)
  end
  return server["with-conn-and-ops-or-warn"]({"add-middleware"}, _4_)
end
_2amodule_2a["load-test-middleware!"] = load_test_middleware_21
local function print_colored_21(text_groups)
  return vim.api.nvim_echo(text_groups, false, {})
end
_2amodule_2a["print-colored!"] = print_colored_21
local function txt_green(text0)
  return {text0, "DiffAdded"}
end
_2amodule_2a["txt-green"] = txt_green
local function txt_red(text0)
  return {text0, "DiffRemoved"}
end
_2amodule_2a["txt-red"] = txt_red
local function txt_yellow(text0)
  return {text0, "diffFile"}
end
_2amodule_2a["txt-yellow"] = txt_yellow
local function txt_normal(text0)
  return {text0}
end
_2amodule_2a["txt-normal"] = txt_normal
local function join_prints(sep_chunk, print_chunks)
  local function _6_(chunk)
    return {chunk, sep_chunk}
  end
  return a.butlast(a.mapcat(_6_, print_chunks))
end
_2amodule_2a["join-prints"] = join_prints
local function pos_3f(n)
  return (n > 0)
end
_2amodule_2a["pos?"] = pos_3f
local function test_resp__3etext_groups(response, descriptions)
  local function _7_(desc)
    local _let_8_ = desc
    local loc = _let_8_[1]
    local color_fn = _let_8_[2]
    local txt_postfix = _let_8_[3]
    local value = a["get-in"](response, loc)
    if pos_3f(value) then
      return color_fn((value .. txt_postfix))
    else
      return nil
    end
  end
  return join_prints(txt_normal(" "), a.map(_7_, descriptions))
end
_2amodule_2a["test-resp->text-groups"] = test_resp__3etext_groups
local function nrepl_test_21(test_selector, printable_info)
  nvim.echo("...")
  log.append({("; Running tests in " .. printable_info)}, {["break?"] = true, ["suppress-hud?"] = true})
  local function _10_(conn, ops)
    local function _11_(response)
      local results = a.get(response, "results")
      local unwrapped_results = display.unwrap(results)
      if results then
        own_state["put-unwrapped-test-results!"](unwrapped_results)
        local lines = display["unwrapped-results->to-lines"](unwrapped_results)
        if (0 == a.count(lines)) then
          print_colored_21(test_resp__3etext_groups(response, {{{"summary", "pass"}, txt_green, " tests passed"}}))
          return log.append({"; Tests passed"}, {["suppress-hud?"] = true})
        else
          print_colored_21(test_resp__3etext_groups(response, {{{"summary", "error"}, txt_red, " errors"}, {{"summary", "fail"}, txt_yellow, " failures"}}))
          return log.append(lines, {["break?"] = true})
        end
      else
        return nil
      end
    end
    return server.send(a.assoc(test_selector, "session", conn.session), _11_)
  end
  return server["with-conn-and-ops-or-warn"]({"test", "test-var-query"}, _10_)
end
_2amodule_2a["nrepl-test!"] = nrepl_test_21
local function nrepl_middleware_run_test_ns_tests_21()
  local test_ns = get_test_ns_name_21()
  return nrepl_test_21({op = "test-var-query", ["var-query"] = {["ns-query"] = {exactly = {test_ns}}}}, test_ns)
end
_2amodule_2a["nrepl-middleware-run-test-ns-tests!"] = nrepl_middleware_run_test_ns_tests_21
local function nrepl_run_current_test_21()
  local form = extract.form({["root?"] = true})
  if form then
    local test_ns = get_test_ns_name_21()
    local test_name = nrepl_action["extract-test-name-from-form"](form.content)
    local printable_info = (test_ns .. "/" .. test_name)
    if test_name then
      return nrepl_test_21({op = "test-var-query", ["var-query"] = {["ns-query"] = {exactly = {test_ns}}, exactly = {(test_ns .. "/" .. test_name)}}}, printable_info)
    else
      return nil
    end
  else
    return nil
  end
end
_2amodule_2a["nrepl-run-current-test!"] = nrepl_run_current_test_21
local function nrepl_jump_to_nth_failing_21()
  return jump["jump-to-buffer-and-line!"](jump["find-buffer-to-jump!"](display["unwrapped-results->nth-test"](own_state["get-unwrapped-test-results"](), vim.v.count1)))
end
_2amodule_2a["nrepl-jump-to-nth-failing!"] = nrepl_jump_to_nth_failing_21
local function jump_to_alternate_ns_21()
  local to_find = get_alternate_ns_name_21()
  return jump["jump-to-buffer-and-line!"](jump["find-buffer-to-jump!"]({namespace = to_find}))
end
_2amodule_2a["jump-to-alternate-ns!"] = jump_to_alternate_ns_21
return _2amodule_2a