Database.Initialize('TPNRP.sqlite')

DAO = {}
DAO.DB = Database

---/********************************/
---/*         Init table           */
---/********************************/

--- Init table 'equipments'
DAO.DB.Execute([[
    CREATE TABLE IF NOT EXISTS equipments (
        citizen_id TEXT,
        items TEXT
    );
]])

--- Init table 'inventories'
DAO.DB.Execute([[
    CREATE TABLE IF NOT EXISTS inventories (
        citizen_id TEXT,
        "type" TEXT,
        items TEXT
    );
]])

--- Init table 'levels'
DAO.DB.Execute([[
    CREATE TABLE IF NOT EXISTS levels (
        citizen_id TEXT,
        "level" INTEGER,
        "exp" INTEGER,
        skills TEXT
    );
]])
--- Init table 'players'
DAO.DB.Execute([[
    CREATE TABLE IF NOT EXISTS players (
        character_id INTEGER PRIMARY KEY AUTOINCREMENT,
        citizen_id TEXT,
        license TEXT,
        name TEXT,
        money TEXT,
        character_info TEXT,
        job TEXT,
        gang TEXT,
        "position" TEXT,
        heading INTEGER,
        metadata TEXT
    );
]])