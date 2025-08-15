local get_python_root_dir = function(bufnr)
	local root_markers = {
		"pyproject.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		".git"
	}
	return vim.fs.root(bufnr, root_markers)
end

local get_python_venv_path = function(bufnr)
	local project_root = get_python_root_dir(bufnr)
	if project_root == nil then
		print("Resolved project_root to nil")
		return nil
	else
		-- this motherfucker resolves the symlink
		-- return vim.fn.resolve(project_root .. "/.venv/bin/python")
		print("Resolved project root to " .. project_root)
		return project_root .. "/.venv/bin/python"
	end
end

return {
	-- preludo buraz
	basedpyright = {
		-- https://docs.basedpyright.com/latest/configuration/language-server-settings/#based-settings
		settings = {
			basedpyright = {
				disableOrganizedImports = true,
				analysis = {
					autoImportCompletions = true,
					-- lets set this to false and see what happens,
					autoSearchPaths = false,
					-- we should define workspace in the basedpyright config
					-- we dont have to set pythonPath because basedpyright is based
					-- https://docs.basedpyright.com/latest/benefits-over-pyright/better-defaults/#default-value-for-pythonpath
					diagnosticMode = "workspace",
					inlayHints = {
						genericTypes = true,
					}
				}
			}
		},
		root_dir = get_python_root_dir
	},
	lua_ls = {
		capabilities = {},
		settings = {
			Lua = {
				completion = {
					callSnippet = 'Replace',
				},
				diagnostics = {
					disable = { 'missing-fields' },
					globals = { "vim" }

				},
			},
		},
	},
	stylua = {},
	ruff = {
		root_dir = get_python_root_dir,
	},
	-- bash language server
	bashls = {},
	-- bash formatting
	shfmt = {},
	-- haskell
	ormolu = {},
	hls = {},
	hlint = {},
	-- ansible
	ansiblels = {},
}
