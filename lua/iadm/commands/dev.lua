local col = Color(176, 237, 92)

local cmd = IADM:AddCommand("lua", function(caller, chat, code)
    RunString(code)
    IADM:MessageWPrefix(caller, true, col, "Ran lua ", Color(255,0,0), code, col, "!")
end)
cmd.Name = "Lua"
cmd.Desc = "Runs a lua code. (Alias of lua_run)"
cmd.ChatArg = true
cmd.PermsRequire = "superadmin"
cmd:AddArgument({type="StrArg", hint="code to run", varargs=true})
