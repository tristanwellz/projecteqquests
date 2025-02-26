function botUnlockPlayer(player_name,unlock_value)
    eq.message(1, "Bot unlock player:" .. player_name);
    local db = Database(Database.Default);
    local stmt = db:prepare("SELECT classes_allowed, number_of_bots FROM bot_unlocks WHERE player_name = ?")
    stmt:execute({ player_name })
    local row = stmt:fetch_hash()
    local raidAccess = false
    if row then
        local current_classes = tonumber(row.classes_allowed)
        if bit.band(current_classes, unlock_value) ~= 0 then
            eq.message(1, "you already unlocked.")
            return
        end
        local new_classes = bit.bor(current_classes,unlock_value)
        if new_classes == 65535 then
            raidAccess = true;
        end
        -- eq.message(1, "New bit number is" ..tostring(new_classes))
        eq.popup("New Bot Class Unlocked!", "You have unlocked a new bot.")
        local new_bot_count = row.number_of_bots + 1
        local stmt = db:prepare("UPDATE bot_unlocks SET number_of_bots = ?, classes_allowed = ?, phinny = ? WHERE player_name = ?")
        stmt:execute({new_bot_count,new_classes,raidAccess,player_name})
    else 
        eq.message(1, "Player did not exist, creating bot unlocks row");
        -- Player does not exist, insert a new row
        local stmt = db:prepare("INSERT INTO bot_unlocks (player_name, number_of_bots, phinny, classes_allowed) VALUES(?, ?, ?, ? )")
        stmt:execute({player_name,1,false,unlock_value})
    end

    db:close()
end

function event_spawn(e)
    -- peq_halloween
    if (eq.is_content_flag_enabled("peq_halloween")) then
        -- exclude mounts and pets
        if (e.self:GetCleanName():findi("mount") or e.self:IsPet()) then
            return;
        end

        -- soulbinders
        -- priest of discord
        if (e.self:GetCleanName():findi("soulbinder") or e.self:GetCleanName():findi("priest of discord")) then
            e.self:ChangeRace(eq.ChooseRandom(14,60,82,85));
            e.self:ChangeSize(6);
            e.self:ChangeTexture(1);
            e.self:ChangeGender(2);
        end

        -- Shadow Haven
        -- The Bazaar
        -- The Plane of Knowledge
        -- Guild Lobby
        local halloween_zones = eq.Set { 202, 150, 151, 344 }
        local not_allowed_bodytypes = eq.Set { 11, 60, 66, 67 }
        if (halloween_zones[eq.get_zone_id()] and not_allowed_bodytypes[e.self:GetBodyType()] == nil) then
            e.self:ChangeRace(eq.ChooseRandom(14,60,82,85));
            e.self:ChangeSize(6);
            e.self:ChangeTexture(1);
            e.self:ChangeGender(2);
        end
    end
end


function event_death(e)
    local topHateClient = e.self:GetHateTopClient();
    -- eq.message(1,"Butts:" .. topHateClient:CharacterID()); -- works
    local player_name = topHateClient:GetName(); -- Get the player's character name
    local npc_name = e.self:GetCleanName();
    -- eq.popup("", "Congratulations npcName: ".. npc_name .. " and PlayerName :" ..  player_name);
    
    if not player_name then return end

    -- -- Mapping of NPCs to class bitmasks
   
    local npc_class_unlocks = {
        ['the froglok king'] = 1,           -- Warrior
        ['King Tranix'] = 2,                -- Cleric
        ['the froglok shin lord'] = 4,      -- Paladin
        ['Master Brewer'] = 8,              -- Ranger
        ['Najena'] = 16,                    -- Shadow Knight
        ['orc trainer'] = 32,               -- Druid
        ['Raster of Guk'] = 64,             -- Monk
        ['Targin the rock'] = 64,           -- Monk
        ['Brother Zephyl'] = 64,            -- Monk
        ['Brother Qwinn'] = 64,             -- Monk
        ['skeleton Lrodd'] = 128,           -- Bard
        ['Lord Pickclaw'] = 256,            -- Rogue
        ["King Thex`Ka IV"] = 512,          -- Shaman
        ['reclusive ghoul magus'] = 1024,   -- Necromancer
        ['reckless efreeti'] = 2048,        -- Wizard
        ['Magi P`Tasa'] = 4096,             -- Magician
        ['a cloaked dhampyre'] = 8192,      -- Enchanter
        ['myconid spore king'] = 16384,     -- Beastlord
        ['Korocust'] = 32768                -- Berserker
    }
    
    
    local unlock_value = npc_class_unlocks[npc_name]
    if not unlock_value then return end -- If NPC isn't in the list, do nothing
    botUnlockPlayer(player_name,unlock_value)
    local group = topHateClient:GetGroup()
    
    if (group.valid) then
        eq.message(1, "group is valid")
        for i = 1,6,1 do
            local member = group:GetMember(i)
            if (member.valid and member:IsClient()) then
                eq.message(1, "member is valid and is client")
                local group_member = member:GetCleanName()
                botUnlockPlayer(group_member,unlock_value)
            end
        end
    else 
        eq.message(1, "group not valid") -- works
    end
    
end
