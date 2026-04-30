return {
  cmd = { 'basedpyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' },
  settings = {
    basedpyright = {
      disableOrganizedImports = true,
      analysis = {
        autoImportCompletions = true,
        autoSearchPaths = false,
        diagnosticMode = "openFilesOnly",
        diagnosticSeverityOverrides = {
          reportAny = false,
          reportUnusedCallResult = false,
          reportMissingTypeStubs = false,
          reportUnknownMemberType = false,
          reportUnknownVariableType = false,
          reportUnknownArgumentType = false,
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
        },
      },
    },
  },
}
