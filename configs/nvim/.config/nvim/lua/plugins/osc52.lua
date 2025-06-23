return {
	"ojroques/nvim-osc52",
	config = function()
		require("osc52").setup({
			max_length = 0, -- no limit
			silent = false,
			trim = false,
		})

		-- Automatically copy yanks to system clipboard using OSC52
		local function copy()
			if vim.v.event.operator == "y" and vim.v.event.regname == "" then
				require("osc52").copy_register("")
			end
		end

		vim.api.nvim_create_autocmd("TextYankPost", { callback = copy })

		-- Optional: custom keymap to copy visually selected text
		-- vim.keymap.set("v", "<leader>c", require("osc52").copy_visual, { desc = "Copy to system clipboard (OSC52)" })
	end,
}
--
