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

-- Detach player from hook
local detach = function(itemstack, placer, pointed_thing)
	placer:set_detach()
end