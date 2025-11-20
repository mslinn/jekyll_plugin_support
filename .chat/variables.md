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

# Where Jekyll Creates Variables

## Overview

Based on analysis of the Jekyll source code (https://github.com/jekyll/jekyll), variables are created and exposed to plugins through a structured system of Liquid drops and rendering pipelines.

## Jekyll Variable Creation Sources

### 1. UnifiedPayloadDrop (Primary Source)
**File**: `lib/jekyll/drops/unified_payload_drop.rb`

**Variables Created**:
- `content` - Page content being processed
- `page` - Current page data via PageDrop
- `layout` - Layout variables 
- `paginator` - Pagination data
- `highlighter_prefix` - Syntax highlighter prefix
- `highlighter_suffix` - Syntax highlighter suffix
- `jekyll` - Global Jekyll variables via JekyllDrop
- `site` - Site data via SiteDrop  
- `theme` - Theme data via ThemeDrop (if theme is active)

### 2. JekyllDrop (Jekyll Global Variables)
**File**: `lib/jekyll/drops/jekyll_drop.rb`

**Variables Created**:
- `version` - Jekyll version number
- `environment` - Current Jekyll environment (development/production)

**Usage**: Available as `{{ jekyll.version }}` and `{{ jekyll.environment }}`

### 3. SiteDrop (Site Variables)
**File**: `lib/jekyll/drops/site_drop.rb`

**Variables Created**:
- `time` - Site generation time
- `pages` - All site pages
- `static_files` - Static files
- `tags` - All tags used in posts
- `categories` - All categories
- `posts` - All posts (sorted newest to oldest)
- `html_pages` - HTML pages
- `collections` - All collections
- `documents` - All documents
- `related_posts` - Related posts for current document

**Collection Access**: Collections are accessible as `site.collection_name` where collection_name is the name of each collection.

### 4. ThemeDrop (Theme Variables)
**File**: `lib/jekyll/drops/theme_drop.rb`

**Variables Created**:
- `root` - Theme root directory (empty in production)
- `authors` - Theme authors
- `version` - Theme version
- `description` - Theme description
- `metadata` - Theme metadata
- `runtime_dependencies` - Theme dependencies

### 5. Document/Page Drops (Document Variables)
**Files**: 
- `lib/jekyll/page.rb` - Page attributes
- `lib/jekyll/document.rb` - Document attributes

**Page Variables** (via `page.to_liquid`):
- `content` - Page content
- `dir` - Page directory
- `excerpt` - Page excerpt
- `name` - Page filename
- `path` - Page path
- `url` - Page URL

**Document Variables** (similar to pages but for posts/documents):
- All page variables plus document-specific attributes
- Front matter variables are also accessible

## How Variables Are Set in the Rendering Pipeline

### Renderer Class (lib/jekyll/renderer.rb)

The Jekyll renderer sets up variables in the Liquid context through several methods:

1. **assign_pages!()** 
   - Sets `payload["page"] = document.to_liquid`
   - Sets `payload["paginator"]` if document has pagination

2. **assign_current_document!()**
   - Sets `payload["site"].current_document = document`

3. **assign_highlighter_options!()**
   - Sets `payload["highlighter_prefix"]` from converter
   - Sets `payload["highlighter_suffix"]` from converter

4. **assign_layout_data!()**
   - Sets `payload["layout"]` by merging layout data with existing layout variables

### Layout Rendering Process

During layout rendering (`render_layout` method):
- Content is assigned to `payload["content"]`
- Layout data is merged into `payload["layout"]`
- Layout variables become available in Liquid templates

### Include Processing

Includes process variables through:
- **File**: `lib/jekyll/inclusion.rb`
- Variables passed to includes are made available in the `include` scope
- Access via `liquid_context.scopes.first['include']['variable_name']`

## Liquid Context Structure

The Liquid context (`liquid_context`) provided to plugins contains:

1. **registers** Hash:
   - `:site` - Site object
   - `:page` - Current page object

2. **environments** Array (first element):
   - Contains the UnifiedPayloadDrop with all primary variables
   - Keys include: `:content`, `:layout`, `:page`, `:paginator`, `:highlighter_prefix`, `:highlighter_suffix`, `:jekyll`, `:site`, `:theme`

3. **scopes** Array:
   - Contains variable scopes for includes, assigned variables, captured variables
   - First scope typically contains include variables under `'include'` key

## Variable Resolution Order

Jekyll resolves variables in this priority order:

1. **registers[:page]** - Direct page object access
2. **registers[:site]** - Direct site object access  
3. **environments.first** - UnifiedPayloadDrop variables
4. **scopes** - Liquid scopes (include, assign, capture variables)

## The Four Previously Flagged Variables Explained

In the previous step, these 4 environment variables were identified as available but unused by `jekyll_plugin_support`. Here's what each one is for:

### `:content` - Page Content
**Purpose**: Contains the HTML/markdown content of the current page being processed.

**Created In**: 
- `lib/jekyll/renderer.rb` - `assign_layout_data!()` method
- Set during layout rendering process

**Usage**: Primarily used for layout rendering to embed page content within layout templates. Example:
```liquid
<html>
  <body>
    {{ content }}
  </body>
</html>
```

**Note**: `jekyll_plugin_support` does not currently access this variable, but it's available in `liquid_context.environments.first[:content]`

### `:highlighter_prefix` - Syntax Highlighter Prefix
**Purpose**: Contains the opening HTML tags for syntax highlighting (typically from Rouge, Pygments, or other syntax highlighters).

**Created In**: 
- `lib/jekyll/renderer.rb` - `assign_highlighter_options!()` method
- Derived from the site's configured syntax highlighter

**Example Value**: Something like `<pre><code class="language-ruby">`

**Usage**: Used by Jekyll's built-in syntax highlighting system to wrap code blocks. Plugins could use this for custom code rendering.

**Note**: Available in `liquid_context.environments.first[:highlighter_prefix]` but not currently used by `jekyll_plugin_support`

### `:highlighter_suffix` - Syntax Highlighter Suffix  
**Purpose**: Contains the closing HTML tags for syntax highlighting to match the prefix.

**Created In**:
- `lib/jekyll/renderer.rb` - `assign_highlighter_options!()` method  
- Derived from the site's configured syntax highlighter

**Example Value**: `</code></pre>`

**Usage**: Used by Jekyll's built-in syntax highlighting system to close code block tags. Should be used together with `highlighter_prefix`.

**Note**: Available in `liquid_context.environments.first[:highlighter_suffix]` but not currently used by `jekyll_plugin_support`

### `:jekyll` - Jekyll Global Variables
**Purpose**: Provides access to global Jekyll information such as version and environment.

**Created In**:
- `lib/jekyll/drops/unified_payload_drop.rb` - via `jekyll` method
- `lib/jekyll/drops/jekyll_drop.rb` - JekyllDrop.global

**Variables Available**:
- `jekyll.version` - Current Jekyll version (e.g., "4.3.2")
- `jekyll.environment` - Current environment ("development", "production", "test")

**Usage**: 
```liquid
Built with Jekyll {{ jekyll.version }} in {{ jekyll.environment }} mode.
```

**Note**: Available in `liquid_context.environments.first[:jekyll]` but not currently exposed to plugins by `jekyll_plugin_support`

## Why These Variables Are Unused

These variables are created and maintained by Jekyll's core rendering system but `jekyll_plugin_support` doesn't currently utilize them because:

1. **Content**: Usually not needed in plugins since page content is already available through other means
2. **Highlighter variables**: These are specialized for code highlighting and most plugins don't need them
3. **Jekyll global**: Can be accessed through other means (e.g., Jekyll::VERSION constant) and plugins typically don't need to know Jekyll's internal version

The framework focuses on the most commonly needed variables: page, site, layout, include, and liquid scopes for maximum plugin compatibility and ease of use.

