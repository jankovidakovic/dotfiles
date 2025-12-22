return {
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

					-- i would want this to be "workspace" but basedpyright is too sluggish
					diagnosticMode = "openFilesOnly",
					diagnosticSeverityOverrides = {
						reportAny = false,
						reportUnusedCallResult = false,
						reportMissingTypeStubs = false,
						reportUnknownMemberType = false,
						reportUnknownVariableType = false,
						reportUnknownArgumentType = false,
						-- jel ti mene jebes
						reportMissingParameterType = false,
						reportUnknownParameterType = false,
						reportExplicitAny = false,
						reportImplicitStringConcatenation = false,
						reportMissingTypeArgument = false,
						reportImplicitRelativeImport = false,
						reportUnannotatedClassAttribute = false,
						reportUntypedFunctionDecorator = false,
						reportImplicitOverride = false,
						reportUnusedParameter = false,
					},
					inlayHints = {
						genericTypes = true,
					}
				}
			}
		},
		root_dir = get_python_root_dir
	},
}
