local meta_ply = FindMetaTable("Player")
if meta_ply then
    function meta_ply:IADMMessage(chat, ...)
        net.Start("iadm_printmsg")
        net.WriteBit(tobool(chat))
        net.WriteTable({...})
        net.Send(self)
    end
end
