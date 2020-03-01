-- Register key listener to detach when jump pressed
local keys_to_be_pressed = "jump"
on_jump_key_pressed = function(keys, old_keys, dtime, player_name)
	if minetest.is_singleplayer() then
		player = minetest.get_player_by_name("singleplayer")
	else
		player = minetest.get_player_by_name(player_name)
	end
	local attached = player:get_attach()
	if attached then
		player:set_detach()
	end
end
keyevent.register_on_keypress(keys_to_be_pressed, on_jump_key_pressed)

-- auto_hook recipe
minetest.register_craft({
	output = 'grappling_hook:auto_hook 1',
	recipe = {
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'',                    'default:string',       ''},
		{'',                    'default:string',       ''}
	}
})

-- auto_hook craftitem
minetest.register_craftitem("grappling_hook:auto_hook", {
	description = ("Pulls player automatically to where hook lands"),
	inventory_image = "grappling_hook_inventory.png",
	stack_max = 16,
})

-- auto_hook throwing API registration
local detach = function(itemstack, placer, pointed_thing)
	placer:set_detach()
end
throwing.register_bow("grappling_hook:auto_hook", {
	itemcraft = "grappling_hook:auto_hook",
	description = "Pulls player automatically to where hook lands",
	texture = "grappling_hook.png",
	wield_image = "grappling_hook.png",
	cooldown = 1,
	delay = 0.4,
	on_place = detach,
	on_secondary_use = detach,
	allow_shot = function(player, itemstack, index)
		return itemstack
	end,
	throw_itself = true,
	-- sound = "sling_throw",
	spawn_arrow_entity = function(pos, arrow, player)
		local obj = minetest.add_entity(pos, "grappling_hook:auto_hook")
		obj:set_properties{
		  textures = {arrow}
		--   nametag = "attachentity"
		}
		return obj
	end
})

-- auto hook minetest entity registration
minetest.register_entity("grappling_hook:auto_hook", throwing.make_arrow_def{
	visual = "wielditem",
	visual_size = {x=0.2, y=0.2},
	collisionbox = {-0.2,-0.2,-0.2, 0.2,0.2,0.2},
	texture = "grappling_hook.png",
	target = throwing.target_node,
	on_hit_sound = "",
	on_throw_sound = "",
	on_hit = function(self, pos, last_pos, node, object, hitter, data)
	  	-- Move hitter by attaching
		local rel_pos = {
			x = 0,
			y = -20,
			z = 0
		}
		local rotation = {x=0, y=0, z=0}
		local stuck_hook = minetest.add_entity(last_pos, "grappling_hook:attach_entity")
		stuck_hook:set_properties{ textures = {stuck_hook:get_luaentity()} }
		hitter:set_attach(stuck_hook, "Arm_Right", rel_pos, rotation)
		
		-- Replace item in inventory
	 	local hitter_inventory = minetest.get_inventory({type="player", name=hitter:get_player_name()})
		local replacement_hook = data.itemstack
		hitter_inventory:set_stack('main', data.index,replacement_hook)
	end,
	on_throw = function(self, pos, thrower, itemstack, index, data)
		data.itemstack = itemstack
		data.index = index
	end,
	sound = {breaks = "default_tool_breaks"},
	on_death = function(self, killer)
		minetest.chat_send_all("killed hook")
	end
})

-- hook entity to attach to
minetest.register_entity("grappling_hook:attach_entity", {
	visual = "wielditem",
	visual_size = {x=0.2, y=0.2},
	collisionbox = {-0.2,-0.2,-0.2, 0.2,0.2,0.2},
	texture = "grappling_hook.png",
	on_detach_child = function(self, child)
		self.object:remove()
	end,
	on_death = function(self, killer)
		minetest.chat_send_all("killed hook")
	end
})