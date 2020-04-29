-- Register key listener to detach when jump pressed
local keys_to_be_pressed = "jump"
on_jump_key_pressed = function(keys, old_keys, dtime, player_name)
	if minetest.is_singleplayer() then
		player_name = 'singleplayer'
	end
	local player = minetest.get_player_by_name(player_name)
	local attached = player:get_attach()
	if attached then
		-- detach
		player:set_detach()
		-- Add hook back to inventory
		local replacement_hook = ItemStack('grappling_hook:auto_hook')
		player:get_inventory():set_stack('main', hook_index, replacement_hook)
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
	  	-- Attach to where hook stuck
		local rel_pos = {
			x = 0,
			y = 0,
			z = 0
		}
		local rotation = {x=0, y=0, z=0}
		local stuck_hook = minetest.add_entity(last_pos, "grappling_hook:attach_entity")
		stuck_hook:set_properties{ textures = {stuck_hook:get_luaentity()} }
		hitter:set_attach(stuck_hook, "Arm_Right", rel_pos, rotation)
	end,
	on_throw = function(self, pos, thrower, itemstack, index, data)
		data.itemstack = itemstack
		data.index = index
		hook_index = index
	end,
	on_hit_fails = function(self, pos, thrower, data)
		-- Attach to where the hook stuck
		local rel_pos = {
			x = 0,
			y = 0,
			z = 0
		}
		local rotation = {x=0, y=0, z=0}
		local stuck_hook = minetest.add_entity(thrower:get_pos(), "grappling_hook:attach_entity")
		stuck_hook:set_properties{ textures = {stuck_hook:get_luaentity()} }
		thrower:set_attach(stuck_hook, "Arm_Right", rel_pos, rotation)
	end,
	sound = {breaks = "default_tool_breaks"},
	on_death = function(self, killer)
		minetest.chat_send_all("killed hook")
	end,
	on_step = function(self, dtime, moveresult)
		-- Called every server step
		-- dtime: Elapsed time
		-- moveresult: Table with collision info (only available if physical=true)
		local rel_pos = {
			x = 0,
			y = 0,
			z = 0
		}
		local rotation = {x=0, y=0, z=0}
		if dtime == 1 then
			local rope = minetest.add_entity(self:get_pos(), "grappling_hook:rope_entity", nil)
			rope:set_attach(self, "Arm_Right", rel_pos, rotation)
		end
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

-- rope entity to connect the hook and the player
minetest.register_entity("grappling_hook:rope_entity", {
    initial_properties = {
		physical = true,
		collide_with_objects = true,	
		collisionbox = {-0.5, 0.0, -0.5, 0.5, 1.0, 0.5},  -- Default
		pointable = true, -- not sure if I should mess with this
		visual = "wielditem",
		visual_size = {x = 1, y = 1, z = 1},
		-- Multipliers for the visual size. If `z` is not specified, `x` will be used
		-- to scale the entity along both horizontal axes.
		mesh = "rope.png",	
		textures = {"grappling_hook:rope_entity"},
		-- Number of required textures depends on visual.
		-- "cube" uses 6 textures just like a node, but all 6 must be defined.
		-- "sprite" uses 1 texture.
		-- "upright_sprite" uses 2 textures: {front, back}.
		-- "wielditem" expects 'textures = {itemname}' (see 'visual' above).
		
		-- Might be needed to move rope dynamically
		automatic_rotate = 0,
		-- Set constant rotation in radians per second, positive or negative.
		-- Set to 0 to disable constant rotation.
		automatic_face_movement_dir = 0.0,
		-- Automatically set yaw to movement direction, offset in degrees.
		-- 'false' to disable.
		automatic_face_movement_max_rotation_per_sec = -1,
		-- Limit automatic rotation to this value in degrees per second.
		-- No limit if value <= 0.
		nametag = "",

		static_save = true,
		-- If false, never save this object statically. It will simply be
		-- deleted when the block gets unloaded.
		-- The get_staticdata() callback is never called then.
		-- Defaults to 'true'.
	},

    -- on_activate = function(self, staticdata, dtime_s),

	on_step = function(self, dtime, moveresult)
		-- Called every server step
		-- dtime: Elapsed time
		-- moveresult: Table with collision info (only available if physical=true)
		local rel_pos = {
			x = 0,
			y = 0,
			z = 0
		}
		local rotation = {x=0, y=0, z=0}
		if dtime == 1 then
			local rope = minetest.add_entity(self:get_pos(), "grappling_hook:rope_entity", nil)
			rope:set_attach(self, "Arm_Right", rel_pos, rotation)
		end
	end

    -- on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir),

    -- on_rightclick = function(self, clicker),

    -- get_staticdata = function(self),
    -- Called sometimes; the string returned is passed to on_activate when
    -- the entity is re-activated from static state

    -- _custom_field = whatever,
    -- You can define arbitrary member variables here (see Item definition
    -- for more info) by using a '_' prefix
})
