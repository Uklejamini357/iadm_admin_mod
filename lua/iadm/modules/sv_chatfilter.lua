-- CURRENTLY NOT IN USE

IADM:AddHook("PlayerSay", "PreventEmptyMessages", function(pl, text)
    if #string.Replace(text, " ", "") == 0 then return "" end
end, HOOK_HIGH)
