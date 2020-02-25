throwing.register_bow("grappling_hook:auto_hook", {
    tiles = {'grappling_hook.png'},
    texture = 'grappling_hook_inventory.png',
    throw_itself = true,
    on_hit = function(self, pos, last_pos, node, object, hitter, data)
		hitter.move_to(last_pos, true)
	end
})

minetest.register_craft({
	output = 'grappling_hook:auto_hook 1',
	recipe = {
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'',                    'default:string',       ''},
		{'',                    'default:string',       ''}
	}
})


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