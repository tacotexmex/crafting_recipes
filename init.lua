if minetest.get_modpath("crafting") then
	-- spairs function licensed CC-BY-SA 3.0
	-- https://stackoverflow.com/questions/15706270/sort-a-table-in-lua
	function spairs(t, order)
		-- collect the keys
		local keys = {}
		for k in pairs(t) do keys[#keys+1] = k end

		-- if order function given, sort by it by passing the table and keys a, b,
		-- otherwise just sort the keys
		if order then
			table.sort(keys, function(a,b) return order(t, a, b) end)
		else
			table.sort(keys)
		end

		-- return the iterator function
		local i = 0
		return function()
			i = i + 1
			if keys[i] then
				return keys[i], t[keys[i]]
			end
		end
	end

	local function combine(recipe)
		local item_counts = {}
		for _, itemstring in pairs(recipe.items) do -- must use pairs here because some slots are nil.
			local stack = ItemStack(itemstring)
			local item_name = stack:get_name()
			item_counts[item_name] = (item_counts[item_name] or 0) + stack:get_count()
		end
		local stacks = {}
		for name, count in pairs(item_counts) do
			table.insert(stacks, name.." "..count)
		end
		return stacks
	end

	minetest.register_on_mods_loaded(function()
		for name in spairs(minetest.registered_items) do
			local recipes = minetest.get_all_craft_recipes(name)
			if recipes then
				for _, recipe in ipairs(recipes) do
					if recipe.method == "normal" or "cooking" then
						local crafting_type = "inv"
						if recipe.method == "cooking" then
							crafting_type = "furnace"
						end
						crafting.register_recipe({
							type = crafting_type,
							output = recipe.output,
							items = combine(recipe),
							always_known = true,
						})
					end
				end
			end
		end
	end)
end
