-- Create new language.
local LANG = IADM:CreateNewLanguage("en", "English")

--[[
Adding new language strings can be done in 2 different ways. However it's preferred to use the first line below.

LANG:AddNewLine("test", "Test!")
LANG.test = "test"
]]
LANG:AddNewLine("No command selected. Currently available commands: ")
LANG:AddNewLine("Invalid command ")
LANG:AddNewLine(". Maybe you meant: ")
LANG:AddNewLine("Dangerous command. Only allow this command to members you trust and if it's necessary.")
LANG:AddNewLine("Usage: %s%s %s")
-- LANG:AddNewLine()

LANG:AddNewLine("players")
LANG:AddNewLine("player")
LANG:AddNewLine("number")
LANG:AddNewLine("text")


-- Punctuation. Cuz why not.
LANG:AddNewLine(".")
LANG:AddNewLine("?")

