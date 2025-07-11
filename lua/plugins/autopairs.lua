-- Automaticaly places closing brackets and newlines
-- return { "jiangmiao/auto-pairs" },

return {
	"windwp/nvim-autopairs",
	enabled = require("nixCatsUtils").enableForCategory("autopairs", true),
	event = "InsertEnter",
	opts = {
		enable_bracket_in_quote = false,
	},
	config = function(_, opts)
		local npairs = require("nvim-autopairs")
		npairs.setup(opts)

		local cond = require("nvim-autopairs.conds")
		local handlers = require("nvim-autopairs.completion.handlers")
		local cmp_autopairs = require("nvim-autopairs.completion.cmp")
		local cmp = require("cmp")
		local Rule = require("nvim-autopairs.rule")

		-- Dont autocomplete if preceeded by a backtick
		local chars = { "{", "(", "[" }
		for _, char in pairs(chars) do
			npairs.get_rules(char)[1]:with_pair(cond.not_before_text("\\"))
		end

		-- Add brackets on completion of function or method
		cmp.event:on(
			"confirm_done",
			cmp_autopairs.on_confirm_done({
				filetypes = {
					-- "*" is a alias to all filetypes
					["*"] = {
						["("] = {
							kind = {
								cmp.lsp.CompletionItemKind.Function,
								cmp.lsp.CompletionItemKind.Method,
							},
							handler = handlers["*"],
						},
					},
				},
			})
		)

		-- Add '{<space>|}' -> {<space>|<space>} + the deletion action
		local brackets = { { "(", ")" }, { "[", "]" }, { "{", "}" } }
		npairs.add_rules({
			-- Rule for a pair with left-side ' ' and right side ' '
			Rule(" ", " ")
				-- Pair will only occur if the conditional function returns true
				:with_pair(function(opts)
					-- We are checking if we are inserting a space in (), [], or {}
					local pair = opts.line:sub(opts.col - 1, opts.col)
					return vim.tbl_contains({
						brackets[1][1] .. brackets[1][2],
						brackets[2][1] .. brackets[2][2],
						brackets[3][1] .. brackets[3][2],
					}, pair)
				end)
				:with_move(cond.none())
				:with_cr(cond.none())
				-- We only want to delete the pair of spaces when the cursor is as such: ( | )
				:with_del(
					function(opts)
						local col = vim.api.nvim_win_get_cursor(0)[2]
						local context = opts.line:sub(col - 1, col + 2)
						return vim.tbl_contains({
							brackets[1][1] .. "  " .. brackets[1][2],
							brackets[2][1] .. "  " .. brackets[2][2],
							brackets[3][1] .. "  " .. brackets[3][2],
						}, context)
					end
				),
		})
		-- For each pair of brackets we will add another rule
		for _, bracket in pairs(brackets) do
			npairs.add_rules({
				-- Each of these rules is for a pair with left-side '( ' and right-side ' )' for each bracket type
				Rule(bracket[1] .. " ", " " .. bracket[2])
					:with_pair(cond.none())
					:with_move(function(opts)
						return opts.char == bracket[2]
					end)
					:with_del(cond.none())
					:use_key(bracket[2])
					-- Removes the trailing whitespace that can occur without this
					:replace_map_cr(function(_)
						return "<C-c>2xi<CR><C-c>O"
					end),
			})
		end
	end,
}
