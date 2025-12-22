return {
	ty = {
		filetypes = { "python" },
		settings = {
			ty = {
				diagnosticMode = "workspace",
				inlayHints = {
					variableTypes = true,
					callArgumentNames = true
				},
				completions = {
					autoImport = true
				}
			}
		}
	}
}
