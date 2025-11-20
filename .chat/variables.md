# Jekyll Variables Access in jekyll_plugin_support

## Overview

This document summarizes how `jekyll_plugin_support` accesses different types of Jekyll variables. The analysis covers all locations where variables are obtained from Jekyll for use in plugins.

## Variable Types and Access Patterns

### 1. Page Variables
**Access Method**: `liquid_context.registers[:page]`

**Locations in Code**:
- `lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:31` - `dump_vars` method
- `lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:47` - `inject_config_vars` method  
- `lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:87` - `lookup_liquid_variables` method
- `lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:146` - `process_page_variables` method
- `lib/helper/jekyll_plugin_helper.rb:88` - Private `page` method
- `lib/tag/jekyll_plugin_support_tag.rb:46` - Tag render method
- `lib/block/jekyll_plugin_support_block.rb:53` - Block render method

**Usage**: Page variables are accessed for variable expansion, error context, and providing page information to plugins.

### 2. Site Variables
**Access Method**: `liquid_context.registers[:site]` or direct `site` parameter

**Locations in Code**:
- `lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:48` - `inject_config_vars` method
- `lib/tag/jekyll_plugin_support_tag.rb:48` - Tag render method
- `lib/block/jekyll_plugin_support_block.rb:55` - Block render method
- `lib/generator/jekyll_plugin_support_generator.rb:15` - Generator generate method (direct parameter)

**Usage**: Site variables provide access to site configuration, collections, and global site data.

### 3. Layout Variables
**Access Method**: `liquid_context.environments.first[:layout]`

**Locations in Code**:
- `lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:89` - `lookup_liquid_variables` method
- `lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:116` - `process_layout_variables` method
- `lib/tag/jekyll_plugin_support_tag.rb:58` - Tag render method
- `lib/block/jekyll_plugin_support_block.rb:65` - Block render method

**Usage**: Layout variables are used for variable expansion within plugin parameters and content.

### 4. Include Variables
**Access Method**: `liquid_context.scopes.first['include']`

**Locations in Code**:
- `lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:102` - `process_included_variables` method
- `demo/variables.html` - Example usage in documentation

**Usage**: Include variables are accessed when plugins are invoked from within Jekyll include files with parameters.

### 5. Liquid Scopes Variables
**Access Method**: `liquid_context.scopes`

**Locations in Code**:
- `lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:32` - `dump_vars` method
- `lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:52` - `inject_config_vars` method
- `lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:93-96` - `lookup_liquid_variables` method
- `lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:130` - `process_liquid_variables` method
- `lib/tag/jekyll_plugin_support_tag.rb:47` - Tag render method
- `lib/block/jekyll_plugin_support_block.rb:54` - Block render method

**Usage**: Liquid scopes contain assigned variables, captured variables, and other Liquid context variables.

### 6. Paginator Variables
**Access Method**: `liquid_context.environments.first[:paginator]`

**Locations in Code**:
- `lib/tag/jekyll_plugin_support_tag.rb:59` - Tag render method
- `lib/block/jekyll_plugin_support_block.rb:66` - Block render method

**Usage**: Paginator variables are available for plugins that need pagination information.

### 7. Theme Variables
**Access Method**: `liquid_context.environments.first[:theme]` or `site.theme`

**Locations in Code**:
- `lib/tag/jekyll_plugin_support_tag.rb:60` - Tag render method
- `lib/block/jekyll_plugin_support_block.rb:67` - Block render method
- `lib/generator/jekyll_plugin_support_generator.rb:18` - Generator generate method

**Usage**: Theme variables provide access to theme-specific configuration and data.

### 8. Other Available Environment Variables (Currently Unused)
**Available Keys**: The `liquid_context.environments.first` hash contains these additional keys that are not currently accessed by `jekyll_plugin_support`:

- `:content` - Page content
- `:highlighter_prefix` - Syntax highlighter prefix
- `:highlighter_suffix` - Syntax highlighter suffix  
- `:jekyll` - Jekyll-specific variables
- `:page` - Page variables (duplicated from registers)
- `:site` - Site variables (duplicated from registers)

**Locations Documented**: 
- `lib/tag/jekyll_plugin_support_tag.rb:57` - Comment lists all available keys
- `lib/block/jekyll_plugin_support_block.rb:64` - Comment lists all available keys

**Usage**: These variables are available but not currently utilized by the framework.

### 9. Config Variables (Custom to jekyll_plugin_support)
**Access Method**: `site.config['liquid_vars']`

**Locations in Code**:
- `lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:50` - `inject_config_vars` method
- `lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:54` - `inject_config_vars` method (environment config)

**Usage**: Custom configuration variables defined in `_config.yml` under the `liquid_vars` section, with environment-specific overrides.

## Variable Expansion Process

The `jekyll_plugin_support` framework performs variable expansion through several coordinated methods:

1. **Configuration Injection**: `inject_config_vars` adds config variables to liquid context
2. **Variable Lookup**: `lookup_liquid_variables` performs the actual substitution
3. **Scope Processing**: Individual scope types are processed in order:
   - Layout variables
   - Page variables  
   - Include variables
   - Liquid variables

## Key Implementation Details

- Variable expansion occurs in the `render` method of both `JekyllTag` and `JekyllBlock` classes
- The process is triggered by calling `JekyllSupport.lookup_liquid_variables`
- Variables are processed in a specific order to handle dependencies correctly
- Error handling is built into each processing method
- The framework handles both tag parameters and block content variable expansion

## Variable Processing Order

1. Configuration variables from `_config.yml`
2. Environment-specific overrides
3. Layout variables
4. Page variables
5. Include variables
6. Liquid variables (assigned/captured)

This order ensures that variables are resolved correctly and that more specific scopes override more general ones appropriately.
