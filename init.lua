minetest.register_craft({
	output = 'grappling_hook:auto_hook 1',
	recipe = {
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'',                    'default:string',       ''},
		{'',                    'default:string',       ''}
	}
})

minetest.register_craftitem("grappling_hook:auto_hook", {
	description = ("Pulls player automatically to where hook lands"),
	inventory_image = "grappling_hook_inventory.png",
	stack_max = 16,
})

throwing.register_bow("grappling_hook:auto_hook", {
  itemcraft = "grappling_hook:auto_hook",
  description = "Pulls player automatically to where hook lands",
  texture = "grappling_hook.png",
  wield_image = "grappling_hook.png",
  cooldown = 1,
  delay = 0.4,
  allow_shot = function(player, itemstack, index)
    -- tomahawk_sneak = player:get_player_control().sneak
    -- local ok = itemstack:get_name() ~= ""
    -- if tomahawk_sneak == true then
    --   return ok
    -- else
    --   return ok, ok and ItemStack(nil)
	-- end
	return itemstack
  end,
	throw_itself = true,
	-- sound = "sling_throw",
  spawn_arrow_entity = function(pos, arrow, player)
    local obj = minetest.add_entity(pos, "grappling_hook:auto_hook")
    -- obj:set_properties{
    --   textures = {arrow},
    -- }
    return obj
  end
})

minetest.register_entity("grappling_hook:auto_hook", throwing.make_arrow_def{
	visual = "wielditem",
	visual_size = {x=0.2, y=0.2},
	collisionbox = {-0.2,-0.2,-0.2, 0.2,0.2,0.2},
	target = throwing.target_node,
	on_hit_sound = "",
	on_throw_sound = "",
	on_activate = function(self, staticdata)
			self.sneak = staticdata == "true"
	end,
	on_hit = function(self, pos, last_pos, node, object, hitter, data)
	  if self.sneak then
		data.itemstack:set_count(1)
	  end
	  minetest.spawn_item(
		{
		  x = math.floor(last_pos.x+0.5),
		  y = math.floor(last_pos.y+0.5),
		  z = math.floor(last_pos.z+0.5)
		},
		data.itemstack
	  )
	end,
	on_throw = function(self, pos, thrower, itemstack, index, data)
		data.itemstack = itemstack
	end,
	  tool_capabilities = {
		  full_punch_interval = 0.8,
		  max_drop_level=1,
		  groupcaps={
			  snappy={times={[1]=2.5, [2]=1.20, [3]=0.35}, uses=30, maxlevel=2},
		  },
		  damage_groups = {fleshy=8},
	  },
	  sound = {breaks = "default_tool_breaks"},
  
  })

-- throwing.register_bow("grappling_hook:auto_hook", {
--     tiles = {'grappling_hook.png'},
--     texture = 'grappling_hook_inventory.png',
--     throw_itself = true,
--     on_hit = function(self, pos, last_pos, node, object, hitter, data)
-- 		hitter.move_to(last_pos, true)
-- 	end
-- })

-- Not using the throwing API, saving in case this doesn't work
-- minetest.register_craftitem("grappling_hook:auto_hook_texture", {
-- 	wield_scale = {x=2,y=2,z=1.0},
-- 	inventory_image = "grappling_hook.png",
-- })

-- minetest.register_craftitem("grappling_hook:auto_hook", {
-- 	description = "Pulls player automatically to where hook lands",
-- 	wield_scale = {x=2,y=2,z=1.0},
-- 	range = 5,
-- 	inventory_image = "grappling_hook_inventory.png",
-- 	stack_max= 200,
-- 	-- on_use = function(itemstack, user, pointed_thing)
-- 	--     -- weapon_shoot(itemstack, user, pointed_thing, 1, "rangedweapons:javelin_entity", 30)
-- 	--     return itemstack
-- 	-- end
-- })

-- local grappling_hook_auto_hook_ENTITY = {
-- 	physical = false,
-- 	timer = 0,
-- 	visual = "wielditem",
-- 	visual_size = {x=0.5, y=0.5},
-- 	textures = {"grappling_hook:auto_hook_texture"},
-- 	lastpos= {},
-- 	collisionbox = {0, 0, 0, 0, 0, 0},
-- }

-- grappling_hook_auto_hook_ENTITY.on_step = function(self, dtime)
-- 	weapon_onstep(self,dtime,0.5,4,1,"grappling_hook:auto_hook_entity","grappling_hook_arrow")
-- end

-- minetest.register_entity("grappling_hook:auto_hook_entity", grappling_hook_auto_hook_ENTITY)