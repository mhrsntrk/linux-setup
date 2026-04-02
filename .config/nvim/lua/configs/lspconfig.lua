local lspconfig = require "lspconfig"

for _, server in ipairs({ "bashls", "gopls", "jsonls", "pyright", "yamlls" }) do
  lspconfig[server].setup {}
end
