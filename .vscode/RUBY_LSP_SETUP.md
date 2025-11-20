# VS Code Setup for Ruby LSP Users

## Required Extensions

Install these extensions (not the deprecated Ruby extension):

1. **Ruby LSP** (Shopify) - Language Server Protocol for Ruby
2. **Ruby Debug** (Rubyroid Labs) - For debugging Ruby code
3. **JRuby Debug** (YusukeEri) - If using JRuby

## Available Debug Configurations

### Option 1: VS Code Debugger (Recommended for debugging)

Use `.vscode/launch.json`:
- **Name**: "Debug Jekyll Demo (Ruby LSP compatible)"
- **Request**: "launch"
- **Type**: "ruby" (compatible with Ruby LSP)
- **Use case**: When you need to debug the Jekyll server or plugins

### Option 2: Manual Launch (Recommended for development)

Use the task: `Ctrl+Shift+P` → "Tasks: Run Task" → "Start Jekyll Demo Server"
- **Use case**: Regular development (no debugging needed)
- **Benefits**: More stable, matches your original working setup

## Using the Configurations

### For Debugging
1. Set breakpoints in your Ruby files
2. F5 or "Debug: Start Debugging" 
3. Select "Debug Jekyll Demo (Ruby LSP compatible)"

### For Regular Development  
1. `Ctrl+Shift+P` → "Tasks: Run Task"
2. Select "Start Jekyll Demo Server"
3. Access site at `http://localhost:4444`

## Why This Works

- **Ruby LSP**: Modern Ruby extension with full language support
- **No deprecated dependencies**: Uses current, maintained extensions
- **Debug stability**: Properly configured for long-running servers
- **Flexible options**: Choose debug or manual launch based on needs

## Verification

To verify the setup works:

1. **Manual test** (should work immediately):
   ```bash
   cd demo && bundle exec jekyll serve --host 0.0.0.0 --port 4444 --livereload_port 25729 --force_polling --future --incremental --livereload --drafts --unpublished
   ```

2. **VS Code debug** (if needed):
   - Set a breakpoint in `demo/_plugins/demo_inline_tag.rb` line 24
   - Start debugging
   - Visit a page with the demo tag to hit the breakpoint

## Troubleshooting

### If debugging still fails:
1. Use the manual task instead
2. Check that Ruby LSP is working: `Ctrl+Shift+P` → "Ruby LSP: Restart Language Server"
3. Verify gem versions: `bundle exec jekyll --version`

### If language features don't work:
1. Ensure you have the Ruby LSP extension installed
2. Check the Ruby LSP status in VS Code status bar
3. Try restarting the language server

The manual approach is always the most reliable for development!