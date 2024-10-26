get_python_root_dir = function(bufnr)
	local root_markers = {
		"pyproject.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		".git"
	}
	return vim.fs.root(bufnr, root_markers)
end

get_python_venv_path = function(bufnr)
	local project_root = get_python_root_dir(bufnr)
	if project_root == nil then
		return nil
	else
		return vim.fn.resolve(project_root .. "/.venv/bin/python")
	end
end

return {
	pyright = {
		root_dir = get_python_root_dir,
		-- settings are getting resolved _immediately_
		-- consequence: if opening a non-python root, get_python_venv_path will return nil
		-- but thats fine as pyright will never even get attached, right?
		-- TODO -- modify so that on_attach loads different settings
		settings = {
			pythonPath = get_python_venv_path(0), -- current buffer
			analysis = {
				autoImportCompletions = true,
				-- enables importing source files without an editable install
				extraPaths = {
					get_python_root_dir(0) -- 0 represents the current buffer, thats okay?
				}
			},
		}
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
	hlint = {}
}
