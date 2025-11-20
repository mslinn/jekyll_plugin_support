# Jekyll Variables Access in jekyll_plugin_support

## Overview

This document summarizes how `jekyll_plugin_support` accesses different types of Jekyll variables. The analysis covers all locations where variables are obtained from Jekyll for use in plugins.

## Recent Fixes and Improvements

### Problems Fixed in Current Session

**Documentation Issues Resolved:**
- ✅ Fixed grammatical error on line 646: "passes" → "passed"
- ✅ Standardized case to "jekyll_plugin_support" throughout documentation
- ✅ Added missing variable types to Variable Expansion section:
  - Include variables 
  - Theme variables
  - Paginator variables
  - Jekyll global variables
- ✅ Added note about variable resolution order

**Implementation Issues Resolved:**
- ✅ **Error Handling Consistency**: Removed `exit! 1` from `process_included_variables` to match other methods
- ✅ **Variable Processing Order**: Reordered to match Jekyll's actual priority:
  1. Page variables
  2. Layout variables  
  3. Jekyll global variables (newly added)
  4. Include variables
  5. Liquid variables
- ✅ **Environment Variable Detection**: Now supports multiple keys:
  - `JEKYLL_ENV`
  - `JEKYLL_ENVIRONMENT` 
  - Site config values
- ✅ **Configuration Injection**: Removed String-only restriction, now supports all data types
- ✅ **New Variable Support**: Added access to Jekyll global variables (`{{jekyll.version}}`, `{{jekyll.environment}}`)
- ✅ **Security Improvements**: Added `sanitize_variable_name` method to prevent regex injection attacks

**Backward Compatibility**: All changes maintain backward compatibility while improving functionality, security, and consistency.

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

---

# Analysis: How jekyll_plugin_support Obtains Variable Names and Values

## Overview

This section analyzes how `jekyll_plugin_support` obtains Jekyll variable names and values, checks the accuracy of the README documentation, and identifies problems in the implementation.

## How Variables Are Obtained

### 1. Entry Point: Liquid Context Access

**Primary Access Methods:**
- `liquid_context.registers[:page]` - Direct page object access
- `liquid_context.registers[:site]` - Direct site object access  
- `liquid_context.environments.first[:layout]` - Layout variables via UnifiedPayloadDrop
- `liquid_context.environments.first[:paginator]` - Pagination data
- `liquid_context.environments.first[:theme]` - Theme data
- `liquid_context.scopes` - Liquid scopes (include, assign, capture variables)

**Locations in Code:**
- `lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:85-100` - `lookup_liquid_variables` method
- `lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:47-68` - `inject_config_vars` method
- `lib/tag/jekyll_plugin_support_tag.rb:45-60` - Tag render method
- `lib/block/jekyll_plugin_support_block.rb:52-67` - Block render method

### 2. Variable Processing Flow

**Step 1: Configuration Injection**
```ruby
# lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:47-68
def self.inject_config_vars(liquid_context)
  site = liquid_context.registers[:site]
  plugin_variables = site.config['liquid_vars']
  scope = liquid_context.scopes.last
  # Environment-specific variable handling
end
```

**Step 2: Variable Lookup and Substitution**
```ruby
# lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:85-100
def self.lookup_liquid_variables(logger, liquid_context, markup_original)
  markup = markup_original.clone
  page   = liquid_context.registers[:page]
  envs   = liquid_context.environments.first
  layout = envs[:layout]
  
  # Process variables in specific order
  markup = process_layout_variables logger, layout, markup
  markup = process_page_variables logger, page, markup
  liquid_context.scopes&.each do |scope|
    markup = process_included_variables logger, scope, markup
    markup = process_liquid_variables logger, scope, markup
  end
  markup
end
```

**Step 3: Individual Variable Processing**
- **Layout Variables**: `process_layout_variables` - processes `{{layout.var}}` patterns
- **Page Variables**: `process_page_variables` - processes `{{page.var}}` patterns
- **Include Variables**: `process_included_variables` - processes `{{include.var}}` patterns
- **Liquid Variables**: `process_liquid_variables` - processes `{{var}}` patterns

### 3. Implementation Details

**String Replacement Strategy:**
Each processing method uses `String#gsub!` to replace variable references with their values:
- Pattern: `"{{scope.#{name}}}"` → `value.to_s`
- Example: `"{{page.title}}"` → `"My Page Title"`

**Error Handling:**
- Each method has comprehensive error handling with `rescue StandardError`
- Different error behaviors: some log and continue, others `exit! 1`
- Detailed error messages with context information

## Problems Identified

### 1. Documentation Accuracy Issues in README.md

**Found In Variable Expansion Section (lines 640-680):**

**Critical Grammatical Error:**
- **Line 646**: "Jekyll does not expand Liquid variable references passes as parameters" 
- **Problem**: "passes" should be "passed"
- **Fix**: "Jekyll does not expand Liquid variable references passed as parameters"

**Case Consistency Issues:**
- **Line 650**: "Jekyll_plugin_support" should be "jekyll_plugin_support"
- **Line 652**: "Jekyll_plugin_support configuration variables" should be "jekyll_plugin_support configuration variables"
- **Line 678**: "Jekyll_plugin_support expands most" should be "jekyll_plugin_support expands most"

**Incomplete Variable List:**
The README states that these variables are expanded:
- Jekyll_plugin_support configuration variables
- Jekyll page and layout variables  
- Inline Liquid variables (assign and capture)

**Missing from Documentation:**
- **Include variables** - These are documented elsewhere but not in the Variable Expansion section
- **Theme variables** - Available but not mentioned
- **Paginator variables** - Available but not mentioned
- **Environment variables** (content, highlighter_prefix, highlighter_suffix, jekyll) - Available but not mentioned

### 2. Implementation Issues

**A. Variable Processing Order Problems**

**Current Order:**
1. Layout variables
2. Page variables
3. Include variables
4. Liquid variables

**Potential Issue**: This order doesn't follow Jekyll's actual resolution priority, which is:
1. registers[:page]
2. registers[:site]
3. environments (layout, paginator, theme, etc.)
4. scopes (include, assign, capture)

**Impact**: Variables might not resolve in the expected priority order, leading to unexpected substitutions.

**B. Error Handling Inconsistencies**

**Different Behaviors Across Methods:**
- `process_layout_variables`: Logs errors but continues processing
- `process_page_variables`: Logs errors but continues processing
- `process_included_variables`: Logs errors and calls `exit! 1` (terminates Jekyll)
- `process_liquid_variables`: Logs errors but continues processing

**Problem**: This inconsistency can lead to confusing behavior where some variable lookup failures terminate the entire Jekyll build while others don't.

**C. Missing Environment Variables Access**

**Available but Unaccessed:**
- `:content` - Could be useful for plugins that need access to rendered page content
- `:highlighter_prefix` and `:highlighter_suffix` - Could be useful for code-related plugins
- `:jekyll` - Global Jekyll information (version, environment)

**Current State**: These variables are extracted from `liquid_context.environments.first` in the tag/block classes but never used in variable expansion.

**D. Performance Concerns**

**Multiple String Replacements:**
Each variable processing method does a complete string scan:
```ruby
markup.gsub!("{{layout.#{name}}}", value.to_s)  # Scans entire string
markup.gsub!("{{page.#{name}}}", value.to_s)    # Scans entire string again
markup.gsub!("{{include.#{name}}}", value.to_s) # Scans entire string again
markup.gsub!("{{#{name}}}", value.to_s)         # Scans entire string again
```

**Potential Issue**: For markup with many variables, this could be inefficient.

**E. Missing Input Validation**

**No Validation on Variable Values:**
- No checking for malicious input in variable values
- No validation that variable values are safe to substitute
- No protection against injection attacks

### 3. Configuration Injection Issues

**A. Hard-Coded Environment Variable**
```ruby
@mode = env&.key?('JEKYLL_ENV') ? env['JEKYLL_ENV'] : 'development'
```
**Issue**: Uses 'JEKYLL_ENV' as the only environment variable key, but Jekyll also supports `JEKYLL_ENVIRONMENT` and defaults to `development` without checking actual Jekyll environment.

**B. Type Restriction Issue**
```ruby
plugin_variables&.each do |name, value|
  scope[name] = value if value.instance_of? String
end
```
**Issue**: Only injects String values, but Jekyll config can contain Hashes, Arrays, and other data types that plugins might need.

### 4. Security Considerations

**A. No HTML Escaping**
Variable values are inserted directly without escaping:
```ruby
markup.gsub!("{{layout.#{name}}}", value.to_s)
```

**Potential Issue**: If variable values contain HTML or JavaScript, this could lead to XSS vulnerabilities in generated content.

**B. Variable Name Sanitization**
No validation that variable names don't contain special characters that could cause unexpected behavior:
```ruby
scope['include']&.each do |name, value|
  markup.gsub!("{{include.#{name}}}", value.to_s)
end
```

**Potential Issue**: Variable names with special regex characters could cause `gsub` to fail or behave unexpectedly.

## Recommendations

### 1. Documentation Fixes
- Fix grammatical error on line 646: "passes" → "passed"
- Standardize case: "jekyll_plugin_support" throughout
- Add missing variable types to Variable Expansion section
- Include include, theme, and paginator variables in documentation

### 2. Implementation Improvements
- Standardize error handling behavior across all processing methods
- Review and potentially reorder variable processing to match Jekyll's priority
- Consider adding access to additional environment variables
- Add input validation and sanitization
- Consider HTML escaping for variable values
- Optimize string replacement performance

### 3. Configuration Enhancement
- Support multiple environment variable keys
- Allow non-String value types in configuration injection
- Add validation for configuration data

These issues, while not critical, represent opportunities for improvement in consistency, performance, security, and documentation accuracy.

