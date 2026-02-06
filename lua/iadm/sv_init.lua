
--[[
    function IADM:OnCommandUsed(caller, ctbl, args, ...)
        local s = {}
        IADM:MessageWPrefix(player.GetAll())
    end
]]

local function Evaluate(pl, caller, format, ...)
	local _f = format
	for c,arg in ipairs({...}) do
		local argtype = type(arg)

		if argtype == "string" then
			_f = string.Replace(_f, "#S", tostring(arg))
		elseif argtype == "number" then
			_f = string.Replace(_f, "#N", tonumber(arg))
		elseif argtype == "boolean" then
			_f = string.Replace(_f, "#B", tostring(arg))
		elseif argtype == "table" and IsValid(arg[1]) then
			if #arg>1 then
				local targets_str = ""
				for i,ply in pairs(arg) do
					if #arg>1 and i == #arg then
						targets_str = targets_str.." and "
					elseif targets_str ~= "" then
						targets_str = targets_str..", "
					end
					targets_str = targets_str..ply:Nick()
				end

				_f = string.Replace(_f, "#T", targets_str)
			else
				_f = string.Replace(_f, "#T", pl == caller and "Yourself" or caller == arg[1] and "Themselves" or arg[1]:Nick())
			end
		elseif IsValid(arg) then
			_f = string.Replace(_f, "#T", arg:Nick())
		end
	end
	return _f
end

function IADM:LogCommandUse(caller, format, args, ...)
    local _,plrs = player.Iterator()
	
	local nick, _f

	local add_args = args and args.silent and "(SILENT) " or ""
    for i,pl in player.Iterator() do
		if pl:IsBot() then continue end
		if args and args.silent then continue end

		nick = IsValid(caller) and caller:Nick() or "(Console)"
		_f = string.Replace(format, "#A", pl == caller and "You" or nick)
        IADM:MessageWPrefix(pl, true, add_args, Evaluate(pl, caller, _f, ...))
    end
	
	nick = IsValid(caller) and caller:Nick() or "(Console)"
	_f = string.Replace(format, "#A", nick)
	IADM:MessageWPrefix(NULL, true, add_args, Evaluate(NULL, caller, _f, ...))
end
