-- HTML tag auto closing
return {
	"windwp/nvim-ts-autotag",
	enabled = require("nixCatsUtils").enableForCategory("ts-autotag", true),
	opts = {
		opts = {
			-- Defaults
			enable_close = true, -- Auto close tags
			enable_rename = true, -- Auto rename pairs of tags
			enable_close_on_slash = false, -- Auto close on trailing </
		},
		per_filetype = {
			["html"] = {
				enable_close = false,
			},
		},
	},
	event = "InsertEnter",
	-- Also override individual filetype configs, these take priority.
	-- Empty by default, useful if one of the "opts" global settings
	-- doesn't work well in a specific filetype
}
