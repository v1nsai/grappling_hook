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
	on_step = function(self, dtime, moveresult)
		minetest.chat_send_all('message')
		minetest.chat_send_all(dtime)
		local rel_pos = {
			x = 0,
			y = 0,
			z = 0
		}
		local rotation = {x=0, y=0, z=0}
		if dtime == 1 then
			local rope = minetest.add_entity(self:get_pos(), "grappling_hook:rope_entity", nil)
			rope:set_attach(self, "", rel_pos, rotation)
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
	end
})

-- rope entity to connect the hook and the player
minetest.register_entity("grappling_hook:rope_entity", {
    initial_properties = {
		physical = true,
		collide_with_objects = true,	
		collisionbox = {-0.5, 0.0, -0.5, 0.5, 1.0, 0.5},  -- Default
		pointable = true,
		visual = "wielditem",
		visual_size = {x = 1, y = 1, z = 1},
		mesh = "rope.png",	
		textures = {"grappling_hook:rope_entity"},
		
		-- Might be needed to move rope dynamically
		automatic_rotate = 0,
		automatic_face_movement_dir = 0.0,
		automatic_face_movement_max_rotation_per_sec = -1,

		nametag = "",
		static_save = true,
	},
	on_step = function(self, dtime, moveresult)
		local rel_pos = {
			x = 0,
			y = 0,
			z = 0
		}
		local rotation = {x=0, y=0, z=0}
		if dtime == 1 then
			local rope = minetest.add_entity(self:get_pos(), "grappling_hook:rope_entity", nil)
			rope:set_attach(self, "", rel_pos, rotation)
		end
	end
})