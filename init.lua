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

-- auto_hook throwing API
throwing.register_bow("grappling_hook:auto_hook", {
  itemcraft = "grappling_hook:auto_hook",
  description = "Pulls player automatically to where hook lands",
  texture = "grappling_hook.png",
  wield_image = "grappling_hook.png",
  cooldown = 1,
  delay = 0.4,
  allow_shot = function(player, itemstack, index)
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
	  hitter.move_to(hitter, {
		x = math.floor(last_pos.x+0.5),
		y = math.floor(last_pos.y+0.5),
		z = math.floor(last_pos.z+0.5)
	  })
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