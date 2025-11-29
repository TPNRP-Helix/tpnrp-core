Database.Initialize('TPNRP.sqlite')

DAO = {}
DAO.DB = Database
DAO.Action = function(ActionType, ...)
    if not ActionType then return end

    local _, result = pcall(function(...)
        return Database[ActionType](...)
    end, ...)

    local ResultSet = {}
    if type(result) == 'userdata' and result.__name == 'TArray' then
        local Rows = result:ToTable()
        for k, v in pairs(Rows) do
            ResultSet[k] = v.Columns:ToTable()
        end
    end
    return #ResultSet ~= 0 and ResultSet or result:ToTable()
end

---/********************************/
---/*         Init table           */
---/********************************/

--- Init table 'missions'
DAO.DB.Execute([[
    CREATE TABLE IF NOT EXISTS player_missions (
        citizen_id VARCHAR(11) NOT NULL UNIQUE,
        missions TEXT
    );
]])

--- Init table 'equipments'
DAO.DB.Execute([[
    CREATE TABLE IF NOT EXISTS equipments (
        citizen_id VARCHAR(11) NOT NULL UNIQUE,
        items TEXT
    );
]])

--- Init table 'inventories'
DAO.DB.Execute([[
    CREATE TABLE IF NOT EXISTS inventories (
        citizen_id VARCHAR(11) NOT NULL UNIQUE,
        items TEXT
    );
]])

--- Init table 'containers'
DAO.DB.Execute([[
    CREATE TABLE IF NOT EXISTS containers (
        container_id VARCHAR(255) UNIQUE,
        citizen_id VARCHAR(11),
        "type" TEXT,
        max_slot INTEGER,
        max_weight INTEGER,
        items TEXT,
        holder_item TEXT,
        is_destroy_on_empty BOOLEAN,
        position TEXT,
        rotation TEXT,
        display_model TEXT
    );
]])

--- Init table 'levels'
DAO.DB.Execute([[
    CREATE TABLE IF NOT EXISTS levels (
        citizen_id VARCHAR(11) NOT NULL UNIQUE,
        "level" INTEGER,
        "exp" INTEGER,
        skills TEXT
    );
]])
--- Init table 'players'
DAO.DB.Execute([[
    CREATE TABLE IF NOT EXISTS players (
        character_id INTEGER PRIMARY KEY AUTOINCREMENT,
        citizen_id VARCHAR(11) NOT NULL UNIQUE,
        license VARCHAR(255),
        name VARCHAR(255),
        money TEXT,
        character_info TEXT,
        job TEXT,
        gang TEXT,
        "position" TEXT,
        heading INTEGER,
        metadata TEXT
    );
]])