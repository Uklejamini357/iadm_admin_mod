return function(MODULE)
    MODULE.BlacklistedWords = MODULE.BlacklistedWords or {}

    IADM:AddHook("PlayerSay", "PreventEmptyMessages", function(pl, text)
        if #string.Replace(text, " ", "") == 0 then return "" end
    end, HOOK_HIGH)

    IADM:AddHook("PlayerSay", "Filter", function(pl, text)
        for _,word in ipairs(MODULE.BlacklistedWords) do
            if string.find(text, word, 1, true) then
                IADM:Message(pl, true, IADM_ECHOCOLOR_WARN, "Your message contained keywords blacklisted by the server!", IADM_ECHOCOLOR_ERROR_HINT, " (", IADM_ECHOCOLOR_ERROR_ARGVAR, word, IADM_ECHOCOLOR_ERROR_HINT, ") ", IADM_ECHOCOLOR_WARN, "Your message was not sent.")
                return ""
            end
        end
    end, HOOK_HIGH)
end
