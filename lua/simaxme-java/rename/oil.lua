local java_rename = require("simaxme-java.rename")
local utils = require("simaxme-java.rename.utils")
local options = require("simaxme-java.options")

local function rename(data)
	local regex = "%.java$"

	local is_java_file = string.find(data.old_name, regex) ~= nil and string.find(data.new_name, regex) ~= nil

	if not is_java_file then
		local root_markers = options.get_java_options().root_markers
		local parts = utils.split_with_patterns(data.old_name, root_markers)

		if #parts <= 1 then
			return nil
		end
	end

	local old_name = data.old_name
	local new_name = utils.realpath(data.new_name)

	local is_dir = utils.is_dir(new_name)

	if not is_dir then
		java_rename.on_rename_file(old_name, new_name)
	else
		local files = utils.list_folder_contents_recursive(new_name)

		for _, file in ipairs(files) do
			local old_file = old_name .. "/" .. file
			local new_file = new_name .. "/" .. file

			java_rename.on_rename_file(old_file, new_file, true)
		end
	end
end

vim.api.nvim_create_autocmd("User", {
	pattern = "OilActionsPost",
	callback = function(event)
		for _, action in pairs(event.data.actions) do
			if action.type == "move" then
				local src = string.sub(action.src_url, 7, -1)
				local dest = string.sub(action.dest_url, 7, -1)
				rename({old_name = src, new_name = dest})
			end
		end
	end,
})

return {}
