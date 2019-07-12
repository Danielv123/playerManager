local normalRestrictions = {
	defines.input_action.add_permission_group,
	defines.input_action.admin_action,
	defines.input_action.change_multiplayer_config,
	defines.input_action.edit_permission_group,
}
local notWhitelistedRestrictions = {
	defines.input_action.activate_cut,
	defines.input_action.add_permission_group,
	defines.input_action.add_train_station,
	defines.input_action.admin_action,
	defines.input_action.alt_select_area,
	defines.input_action.alt_select_blueprint_entities,
	defines.input_action.alternative_copy,
	defines.input_action.build_terrain,
	defines.input_action.cancel_research,
	defines.input_action.change_arithmetic_combinator_parameters,
	defines.input_action.change_blueprint_book_record_label,
	defines.input_action.change_decider_combinator_parameters,
	defines.input_action.change_item_label,
	defines.input_action.change_multiplayer_config,
	defines.input_action.change_programmable_speaker_alert_parameters,
	defines.input_action.change_programmable_speaker_circuit_parameters,
	defines.input_action.change_programmable_speaker_parameters,
	defines.input_action.change_single_blueprint_record_label,
	defines.input_action.change_train_stop_station,
	defines.input_action.change_train_wait_condition,
	defines.input_action.change_train_wait_condition_data,
	defines.input_action.clear_selected_blueprint,
	defines.input_action.clear_selected_deconstruction_item,
	defines.input_action.clear_selected_upgrade_item,
	defines.input_action.connect_rolling_stock,
	defines.input_action.create_blueprint_like,
	defines.input_action.custom_input,
	defines.input_action.cycle_blueprint_book_backwards,
	defines.input_action.cycle_blueprint_book_forwards,
	defines.input_action.deconstruct,
	defines.input_action.delete_blueprint_library,
	defines.input_action.delete_blueprint_record,
	defines.input_action.delete_custom_tag,
	defines.input_action.delete_permission_group,
	defines.input_action.destroy_opened_item,
	defines.input_action.disconnect_rolling_stock,
	defines.input_action.drag_train_schedule,
	defines.input_action.drag_train_wait_condition,
	defines.input_action.drop_blueprint_record,
	defines.input_action.drop_item,
	defines.input_action.drop_to_blueprint_book,
	defines.input_action.edit_custom_tag,
	defines.input_action.edit_permission_group,
	defines.input_action.export_blueprint,
	defines.input_action.grab_blueprint_record,
	defines.input_action.import_blueprint,
	defines.input_action.import_blueprint_string,
	defines.input_action.import_permissions_string,
	defines.input_action.launch_rocket,
	defines.input_action.lua_shortcut,
	defines.input_action.map_editor_action,
	defines.input_action.market_offer,
	defines.input_action.mod_settings_changed,
	defines.input_action.open_blueprint_library_gui,
	defines.input_action.open_blueprint_record,
	defines.input_action.open_bonus_gui,
	defines.input_action.open_tutorials_gui,
	defines.input_action.paste_entity_settings,
	defines.input_action.remove_cables,
	defines.input_action.remove_train_station,
	defines.input_action.reset_assembling_machine,
	defines.input_action.select_blueprint_entities,
	defines.input_action.set_auto_launch_rocket,
	defines.input_action.set_autosort_inventory,
	defines.input_action.set_behavior_mode,
	defines.input_action.set_circuit_condition,
	defines.input_action.set_circuit_mode_of_operation,
	defines.input_action.set_deconstruction_item_tile_selection_mode,
	defines.input_action.set_deconstruction_item_trees_and_rocks_only,
	defines.input_action.set_entity_energy_property,
	defines.input_action.set_heat_interface_mode,
	defines.input_action.set_heat_interface_temperature,
	defines.input_action.set_infinity_container_filter_item,
	defines.input_action.set_infinity_container_remove_unfiltered_items,
	defines.input_action.set_infinity_pipe_filter,
	defines.input_action.set_inserter_max_stack_size,
	defines.input_action.set_research_finished_stops_game,
	defines.input_action.set_single_blueprint_record_icon,
	defines.input_action.set_train_stopped,
	defines.input_action.setup_blueprint,
	defines.input_action.setup_single_blueprint_record,
	defines.input_action.start_research,
	defines.input_action.switch_connect_to_logistic_network,
	defines.input_action.switch_constant_combinator_state,
	defines.input_action.switch_inserter_filter_mode_state,
	defines.input_action.switch_power_switch_state,
	defines.input_action.switch_to_rename_stop_gui,
	defines.input_action.toggle_deconstruction_item_entity_filter_mode,
	defines.input_action.toggle_deconstruction_item_tile_filter_mode,
	defines.input_action.toggle_map_editor,
	defines.input_action.upgrade,
	defines.input_action.upgrade_opened_blueprint,
	defines.input_action.use_artillery_remote
}

local function setAdminPermissions(permission_group)
	for name, val in pairs(defines.input_action) do
        permission_group.set_allows_action(val, true)
    end
end
local function setRestrictions(permission_group, restrictions)
	setAdminPermissions(permission_group)
	for i, val in ipairs(restrictions) do
        permission_group.set_allows_action(val, false)
    end
end

local function createPermissionGroupsLocal()
	if not game.permissions.get_group('Admin')  then
		game.permissions.create_group('Admin')
	end
	if not game.permissions.get_group('Standard')  then
		game.permissions.create_group('Standard')
	end
	if global.inventorySyncEnabled == true then
		log('Loading Permission Group Default using restricted permissions...')
		setRestrictions(game.permissions.get_group('Default'), notWhitelistedRestrictions)
	else
		log('Loading Permission Group Default using normal permissions...')
		setRestrictions(game.permissions.get_group('Default'), normalRestrictions)
	end
	log('Loading Permission Group Standard...')
	setRestrictions(game.permissions.get_group('Standard'), normalRestrictions)
	log('Loading Permission Group Admin...')
	setAdminPermissions(game.permissions.get_group('Admin'))
end

local function backupPlayerStuff(player)
--	if not (player and player.character) then
--		return
--	end

	local inventories = {
		player.get_inventory(defines.inventory.character_guns),
		player.get_inventory(defines.inventory.character_ammo),
		player.get_inventory(defines.inventory.character_trash),
		player.get_inventory(defines.inventory.character_main),
		player.get_inventory(defines.inventory.character_armor),
	}

	local inventory_size = 0
	for i, inventory in ipairs(inventories) do
		for i=1, #inventory do
			if inventory[i].valid and inventory[i].valid_for_read and inventory[i].count > 0 then
				inventory_size = inventory_size + 1
			end
		end
	end

	local position = {0,0}
	if player.character then position = player.character.position end

	local corpse = player.surface.create_entity{
		name = "character-corpse",
		position = position,
		force = player.force,
		inventory_size = inventory_size,
		player_index = player.index,
	}

	local corpse_inv = corpse.get_inventory(defines.inventory.character_corpse)
	for i, inventory in ipairs(inventories) do
		for i=1, #inventory do
			corpse_inv.insert(inventory[i])
		end
		inventory.clear()
	end
end

local function deserialize_grid(grid, data)
	grid.clear()
	local names, energy, shield, xs, ys = data.names, data.energy, data.shield, data.xs, data.ys
	for i = 1, #names do
		local equipment = grid.put({
			name = names[i],
			position = {xs[i], ys[i]}
		})

		if equipment then
			if shield[i] > 0 then
				equipment.shield = shield[i]
			end
			if energy[i] > 0 then
				equipment.energy = energy[i]
			end
		end
	end
end

local function deserialize_inventory(inventory, data)
    local item_names, item_counts, item_durabilities,
    item_ammos, item_exports, item_labels, item_grids
    = data.item_names, data.item_counts, data.item_durabilities,
    data.item_ammos, data.item_exports, data.item_labels, data.item_grids
    for idx, name in pairs(item_names) do
        local slot = inventory[idx]
        slot.set_stack({
            name = name,
            count = item_counts[idx]
        })
        if item_durabilities[idx] ~= nil then
            slot.durability = item_durabilities[idx]
        end
        if item_ammos[idx] ~= nil then
            slot.ammo = item_ammos[idx]
        end
        local label = item_labels[idx]
		-- We got a crash on line 1 of this IF statement with AAI programmable vehicles's unit-remote-control item where label = {allow_manual_label_change = true}
		-- we attempt to fix this by checking slot.is_item_with_label, but we have no idea if this property is set properly. Label syncing might be broken.
        if label and slot.is_item_with_label then
            slot.label = label.label
            slot.label_color = label.label_color
            slot.allow_manual_label_change = label.allow_manual_label_change
        end

        local grid = item_grids[idx]
        if grid then
            deserialize_grid(slot.grid, grid)
        end
    end
    for idx, str in pairs(item_exports) do
        local success = inventory[idx].import_stack(str)
        if success == -1 then
            print("item imported with errors")
        elseif success == 1 then
            print("failed to import item")
        end

    end
    if data.filters then
        for idx, filter in pairs(data.filters) do
            inventory.set_filter(idx, filter)
        end
    end
end

-- functions for exporting a players data
--[[Misc functions for serializing stuff]]
local inventory_types = {}
do
    local map = {}
    for _, inventory_type in pairs(defines.inventory) do
        map[inventory_type] = true
    end
    for t in pairs(map) do
        inventory_types[#inventory_types + 1] = t
    end
    table.sort(inventory_types)
end
local function serialize_equipment_grid(grid)
	local names, energy, shield, xs, ys = {}, {}, {}, {}, {}

	local position = {0,0}
	local width, height = grid.width, grid.height
	local processed = {}
	for y = 0, height - 1 do
		for x = 0, width - 1 do
			local base = (y + 1) * width + x + 1
			if not processed[base] then
				position[1], position[2] = x, y
				local equipment = grid.get(position)
				if equipment ~= nil then
					local shape = equipment.shape
					for j = 0, shape.height - 1 do
						for i = 0, shape.width - 1 do
							processed[base + j * width + i] = true
						end
					end

					local idx = #names + 1
					names[idx] = equipment.name
					energy[idx] = equipment.energy
					shield[idx] = equipment.shield
					xs[idx] = x
					ys[idx] = y
				end
			end
		end
	end
	return {
		names = names,
		energy = energy,
		shield = shield,
		xs = xs,
		ys = ys,
	}
end
--[[ serialize an inventory ]]
local function serialize_inventory(inventory)
	local filters
	if inventory.supports_filters() then
		filters = {}
		for i = 1, #inventory do
			filters[i] = inventory.get_filter(i)
		end
	end
	local item_names, item_counts, item_durabilities,
	item_ammos, item_exports, item_labels, item_grids
	= {}, {}, {}, {}, {}, {}, {}

	for i = 1, #inventory do
		local slot = inventory[i]
		if slot.valid_for_read then
			if slot.is_blueprint or slot.is_blueprint_book or slot.is_upgrade_item
					or slot.is_deconstruction_item or slot.is_item_with_tags then
				local success, export = pcall(slot.export_stack)
				if not success then
					print("failed to export item")
				else
					item_exports[i] = export
				end
			elseif slot.is_item_with_inventory then
				print("sending items with inventory is not allowed")
			else
				item_names[i] = slot.name
				item_counts[i] = slot.count
				local durability = slot.durability
				if durability ~= nil then
					item_durabilities[i] = durability
				end
				if slot.type == "ammo" then
					item_ammos[i] = slot.ammo
				end
				if slot.is_item_with_label then
					item_labels[i] = {
						label = slot.label,
						label_color = slot.label_color,
						allow_manual_label_change = slot.allow_manual_label_change,
					}
				end

				local grid = slot.grid
				if grid then
					item_grids[i] = serialize_equipment_grid(grid)
				end
			end
		end
	end

	return {
		filters = filters,
		item_names = item_names,
		item_counts = item_counts,
		item_durabilities = item_durabilities,
		item_ammos = item_ammos,
		item_exports = item_exports,
		item_labels = item_labels,
		item_grids = item_grids,
	}
end


local function serialize_quickbar(player)
	local quickbar_names = {}
	for i=1, 100 do
		local slot = player.get_quick_bar_slot(i)
		if slot ~= nil then
			table.insert(quickbar_names, slot.name)
		else
			table.insert(quickbar_names, "")
		end
	end
	return quickbar_names
end

local function deserialize_quickbar(player, quickbar)
	for index, name in ipairs(quickbar) do
		if name ~= "" then
			player.set_quick_bar_slot(index, name)
		else
			player.set_quick_bar_slot(index, nil)
		end
	end
end

local function serialize_player(player)
	local seed = game.surfaces[1].map_gen_settings.seed
	local playerData = ""
	--[[ Collect info about the player for identification ]]
	playerData = playerData .. "|name:"..player.name.."~index:"..player.index.."~connected:"..tostring(player.connected)
	playerData = playerData .. "~r:"..tostring(player.color.r).."~g:"..tostring(player.color.g).."~b:"..tostring(player.color.b).."~a:"..tostring(player.color.a)
	playerData = playerData .. "~cr:"..tostring(player.chat_color.r).."~cg:"..tostring(player.chat_color.g).."~cb:"..tostring(player.chat_color.b).."~ca:"..tostring(player.chat_color.a)
	playerData = playerData .. "~tag:"..tostring(player.tag)
	--[[ Collect players system information ]]
	playerData = playerData .. "~displayWidth:"..player.display_resolution.width.."~displayHeight:"..player.display_resolution.height.."~displayScale:"..player.display_scale
	
	--[[ Collect game/tool specific information from player ]]
	playerData = playerData .. "~afkTime"..seed..":"..player.afk_time.."~onlineTime"..seed..":"..player.online_time.."~admin:"..tostring(player.admin).."~spectator:"..tostring(player.spectator)
	playerData = playerData .. "~forceName:"..player.force.name
	
	local inventories = {}
	for _, inventory_type in pairs(inventory_types) do
		local inventory = player.get_inventory(inventory_type)
		if inventory then
			inventories[inventory_type] = serialize_inventory(inventory)
		end
	end
	playerData = playerData .. "~inventory:"..serpent.line(inventories)

	local quickbar = serialize_quickbar(player)
	playerData = playerData .. "~quickbar:"..serpent.line(quickbar)
	return playerData
end

local function deserialize_player(player)
	player.ticks_to_respawn = nil
	local ok, invTable = serpent.load(invData)
	local ok, quickbarTable = serpent.load(quickbarData)

	global.inventorySynced= global.inventorySynced or {}

	if global.inventorySynced[player.index] == nil then
		backupPlayerStuff(player)
	end

	-- sync misc details
	player.force = forceName
	player.spectator = spectator
	player.admin = admin
	player.color = color
	player.chat_color = chat_color
	player.tag = tag

	-- Clear old inventories
	player.get_inventory(defines.inventory.character_guns).clear()
	player.get_inventory(defines.inventory.character_ammo).clear()
	player.get_inventory(defines.inventory.character_trash).clear()
	player.get_inventory(defines.inventory.character_main).clear()
	-- clear armor last to avoid inventory spilling
	player.get_inventory(defines.inventory.character_armor).clear()

	-- 3: pistol.
	deserialize_inventory(player.get_inventory(defines.inventory.character_guns), invTable[3])
	-- 4: Ammo.
	deserialize_inventory(player.get_inventory(defines.inventory.character_ammo), invTable[4])
	-- 5: armor.
	deserialize_inventory(player.get_inventory(defines.inventory.character_armor), invTable[5])
	-- 8: express-transport-belt (trash slots)
	deserialize_inventory(player.get_inventory(defines.inventory.character_trash), invTable[8])
	-- 1: Main inventory (do that AFTER armor, otherwise there won't be space)
	deserialize_inventory(player.get_inventory(defines.inventory.character_main), invTable[1])

	deserialize_quickbar(player, quickbarTable)

	player.print("Inventory synchronized.")
	global.inventorySynced[player.index] = true
end


-- event helpers
local function rockets_launched()
	return game.forces["player"].rockets_launched
end
local function enemies_left()
	local force = game.forces["enemy"]
	local protoypes = {"behemoth-biter", "behemoth-spitter", "big-biter", "big-spitter", "medium-biter", "medium-spitter", "small-biter", "small-spitter", "biter-spawner", "spitter-spawner", "behemoth-worm-turret", "big-worm-turret", "medium-worm-turret", "small-worm-turret"}
	local enemies_left = 0
	for _, prototype in pairs(protoypes) do
		enemies_left = enemies_left + force.get_entity_count(prototype)
	end

	return enemies_left
end

local function defaultSyncConditionCheck()
	if global.inventorySyncEnabled then
		return
	end

	-- if rockets_launched() == 0 then return end
	-- if enemies_left() > 0 then return end

	if rockets_launched() == 0 and enemies_left() > 0 then return end

	for _, player in pairs(game.players) do
		if player.connected then
			backupPlayerStuff(player)
			table.insert(global.playersToImport, player.name)
			player.print("Preparing profile sync...")
		end
	end

	createPermissionGroupsLocal()

	global.inventorySyncEnabled = true
end
script.on_nth_tick(60, defaultSyncConditionCheck)

script.on_init(function()
	global.playersToImport = {}
	global.playersToExport = ""
	global.inventory_types = {}
	global.inventorySynced = {} -- array of player_index=>bool
	global.inventorySyncEnabled = true
	do
		local map = {}
		for _, inventory_type in pairs(defines.inventory) do
			map[inventory_type] = true
		end
		for t in pairs(map) do
			global.inventory_types[#global.inventory_types + 1] = t
		end
		table.sort(global.inventory_types)
	end
end)

script.on_event(defines.events.on_player_joined_game, function(event)
	if not global.inventorySyncEnabled then
		return
	end

    local player = game.players[event.player_index]
    table.insert(global.playersToImport, player.name)
    player.print("Registered you joining the game, preparing profile sync...")
end)

script.on_event(defines.events.on_player_left_game, function(event)
	if not (global.inventorySynced and global.inventorySynced[event.player_index]) then
		return
	end
	local player = game.players[event.player_index]
	global.playersToExport = global.playersToExport .. serialize_player(player)
	game.print("Registered "..player.name.." leaving the game, preparing for upload...")

	global.inventorySynced[event.player_index] = false
end)

remote.remove_interface("playerManager")
remote.add_interface("playerManager", {
	enableInventorySync = function()
		global.inventorySyncEnabled = true
	end,
	disableInventorySync = function()
		global.inventorySyncEnabled = false
	end,
	runCode = function(code)
		load(code, "playerTracking code injection failed!", "t", _ENV)()
	end,
	getImportTask = function()
		if #global.playersToImport >= 1 then
			local playerName = table.remove(global.playersToImport, 1)
			rcon.print(playerName)
			game.print("Downloading account for "..playerName.."...")
		end
	end,
	importInventory = function(playerName, invData, quickbarData, forceName, spectator, admin, color, chat_color, tag)
		local player = game.players[playerName]
        if player and player.connected then
		    deserialize_player(player, invData, quickbarData, forceName, spectator, admin, color, chat_color, tag)
        else
            game.print("Player "..playerName.." left before they could get their inventory!")
        end
	end,
	resetInvImportQueue = function()
		global.playersToImport = {}
	end,
	exportPlayers = function()
		rcon.print(global.playersToExport)
		if global.playersToExport and string.len(global.playersToExport) > 10 then
			game.print("Exported player profiles")
		end
		global.playersToExport = ""
	end,
	setPlayerPermissionGroup = function(playerName, permissionGroupName)
		-- if player is admin, dont change group. This is to stop the whitelist
		-- from overwriting the admin list.
		local player = game.permissions.get_group("Admin").players[playerName]
		if player then return end
		log('Adding '..playerName..' to group '..permissionGroupName)
		game.permissions.get_group(permissionGroupName).add_player(playerName)
		if permissionGroupName == "Admin" then
			game.players[playerName].admin = true
		end
	end,
	-- Creates permission group definitions.
	createPermissionGroups = function()
		createPermissionGroupsLocal();
	end

})
