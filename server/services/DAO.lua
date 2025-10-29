Database.Initialize('TPNRP.db')

DAO = {}
DAO.DB = Database

---Get player by citizen id
---@param citizen_id string
DAO.getPlayer = function(citizen_id)
    local result = DAO.DB.Select('SELECT * FROM players where citizen_id = ?', { citizen_id })
    local PlayerData = result[1] and result[1].Columns:ToTable()

    -- Validate PlayerData
    if PlayerData then
        return PlayerData
    end

    return nil
end

DAO.loadPlayer = function(player)
    -- TODO:
end

DAO.deletePlayer = function(player)
    -- TODO:
end