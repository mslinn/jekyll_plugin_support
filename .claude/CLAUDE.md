# Jekyll Plugin Support Instructions for Claude

## General Instructions

- Read `.chat/RUBY_STANDARDS.md` so you can learn about Ruby coding
  instructions.

- Do not use emojis in user dialog or documentation.

- Do not use superlatives; instead, be strictly factual.

- Do not ask the user several questions at once.
  Instead, make a list of questions and ask your questions one at a time.

- Make no assumptions. Ask the user about every ambiguity or corner case, and
  suggest a better way if there is one. Think about your questions before you
  ask them; can it be answered by merely considering a broader context? If so,
  make that a provisional assumption and ask for confirmation.

- If you need to write documentation, place the file in the `docs/` directory.

- Before running every git command, check if `.git/index.lock` exists, and delete it using `sudo` if so.

- Git projects have environment variables that point to their directories. Some examples:

  - `$jekyll_plugin_support` points to the directory containing the
    `jekyll_plugin_support` Git project.
  - `$jekyll_href` points to the directory containing the `jekyll_href` Git
    project that defines the `href` plugin.
  - `$jekyll_pre` points to the directory containing the `jekyll_pre` Git
    project that defines the `pre` plugin.
  - `$jekyll_img` points to the directory containing the `jekyll_img` Git
    project that defines the `img` plugin.
  - `$jekyll_flexible_include_plugin` points to the
    `jekyll_flexible_include_plugin` Git project that contains the directory
    containing the `flexible_include` plugin.


## Requirements for Done

The following must be completed before your work can be considered to be done.

- Update documentation with changes
- Unit tests must pass
- Linters for all languages (bash, Ruby, Markdown, etc) must succeed.
- Unit tests must pass.
- Update `README.md` for user-visible changes only.
- Update `CHANGES.md` for programmer-visible changes, described at a high level.
- Update `.chat/PROGRESS.md`.
- Only then `git push` with a message and commit.


## Do This Now

when I tried to launch the demo jekyll website, the following appeared:

```
ERROR Draft: /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/document.rb:413:in 'Jekyll::Document#method_missing': undefined met ... gins/jekyll_plugin_support/binstub/jekyll:16:in 'Kernel#load'
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/binstub/jekyll:16:in '<main>'

ERROR Draft: /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/document.rb:413:in 'Jekyll::Document#method_missing': undefined met ... gins/jekyll_plugin_support/binstub/jekyll:16:in 'Kernel#load'
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/binstub/jekyll:16:in '<main>'

ERROR Draft: /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/document.rb:413:in 'Jekyll::Document#method_missing': undefined met ... gins/jekyll_plugin_support/binstub/jekyll:16:in 'Kernel#load'
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/binstub/jekyll:16:in '<main>'

ERROR JekyllSupport::HRefTag: /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:172:in 'JekyllSupport.process_jekyll_variables': undefined method 'each' for an instance of Jekyll::Drops::JekyllDrop (NoMethodError)

    jekyll&.each do |name, value|
          ^^^^^^
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:105:in 'JekyllSupport.lookup_liquid_variables'
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/lib/tag/jekyll_plugin_support_tag.rb:65:in 'JekyllSupport::JekyllTag#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/block_body.rb:103:in 'Liquid::BlockBody#render_node_to_output'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/block_body.rb:91:in 'Liquid::BlockBody#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/template.rb:206:in 'block in Liquid::Template#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/template.rb:240:in 'Liquid::Template#with_profiling'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/template.rb:205:in 'Liquid::Template#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/template.rb:218:in 'Liquid::Template#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:39:in 'block (3 levels) in Jekyll::LiquidRenderer::File#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:59:in 'Jekyll::LiquidRenderer::File#measure_counts'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:38:in 'block (2 levels) in Jekyll::LiquidRenderer::File#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:63:in 'Jekyll::LiquidRenderer::File#measure_bytes'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:37:in 'block in Jekyll::LiquidRenderer::File#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:70:in 'Jekyll::LiquidRenderer::File#measure_time'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:36:in 'Jekyll::LiquidRenderer::File#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/renderer.rb:129:in 'Jekyll::Renderer#render_liquid'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/renderer.rb:80:in 'Jekyll::Renderer#render_document'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/renderer.rb:63:in 'Jekyll::Renderer#run'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:572:in 'Jekyll::Site#render_regenerated'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:557:in 'block (2 levels) in Jekyll::Site#render_docs'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:556:in 'Array#each'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:556:in 'block in Jekyll::Site#render_docs'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:555:in 'Hash#each_value'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:555:in 'Jekyll::Site#render_docs'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:210:in 'Jekyll::Site#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:80:in 'Jekyll::Site#process'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/command.rb:28:in 'Jekyll::Command.process_site'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/commands/build.rb:65:in 'Jekyll::Commands::Build.build'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/commands/build.rb:36:in 'Jekyll::Commands::Build.process'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/command.rb:91:in 'block in Jekyll::Command.process_with_graceful_fail'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/command.rb:91:in 'Array#each'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/command.rb:91:in 'Jekyll::Command.process_with_graceful_fail'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/commands/serve.rb:85:in 'block (2 levels) in Jekyll::Commands::Serve.init_with_program'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary/command.rb:221:in 'block in Mercenary::Command#execute'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary/command.rb:221:in 'Array#each'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary/command.rb:221:in 'Mercenary::Command#execute'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary/program.rb:44:in 'Mercenary::Program#go'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary.rb:21:in 'Mercenary.program'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/exe/jekyll:15:in '<top (required)>'
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/binstub/jekyll:16:in 'Kernel#load'
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/binstub/jekyll:16:in '<main>'

WARN JekyllSupport::HRefTag: markup is a TrueClass, not a String
ERROR JekyllBadge::JekyllBadge: /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:172:in 'JekyllSupport.process_jekyll_variables': undefined method 'each' for an instance of Jekyll::Drops::JekyllDrop (NoMethodError)

    jekyll&.each do |name, value|
          ^^^^^^
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:105:in 'JekyllSupport.lookup_liquid_variables'
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/lib/tag/jekyll_plugin_support_tag.rb:65:in 'JekyllSupport::JekyllTag#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/block_body.rb:103:in 'Liquid::BlockBody#render_node_to_output'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/block_body.rb:91:in 'Liquid::BlockBody#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/template.rb:206:in 'block in Liquid::Template#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/template.rb:240:in 'Liquid::Template#with_profiling'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/template.rb:205:in 'Liquid::Template#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/template.rb:218:in 'Liquid::Template#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:39:in 'block (3 levels) in Jekyll::LiquidRenderer::File#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:59:in 'Jekyll::LiquidRenderer::File#measure_counts'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:38:in 'block (2 levels) in Jekyll::LiquidRenderer::File#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:63:in 'Jekyll::LiquidRenderer::File#measure_bytes'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:37:in 'block in Jekyll::LiquidRenderer::File#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:70:in 'Jekyll::LiquidRenderer::File#measure_time'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:36:in 'Jekyll::LiquidRenderer::File#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/renderer.rb:129:in 'Jekyll::Renderer#render_liquid'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/renderer.rb:80:in 'Jekyll::Renderer#render_document'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/renderer.rb:63:in 'Jekyll::Renderer#run'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:572:in 'Jekyll::Site#render_regenerated'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:557:in 'block (2 levels) in Jekyll::Site#render_docs'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:556:in 'Array#each'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:556:in 'block in Jekyll::Site#render_docs'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:555:in 'Hash#each_value'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:555:in 'Jekyll::Site#render_docs'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:210:in 'Jekyll::Site#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:80:in 'Jekyll::Site#process'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/command.rb:28:in 'Jekyll::Command.process_site'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/commands/build.rb:65:in 'Jekyll::Commands::Build.build'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/commands/build.rb:36:in 'Jekyll::Commands::Build.process'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/command.rb:91:in 'block in Jekyll::Command.process_with_graceful_fail'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/command.rb:91:in 'Array#each'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/command.rb:91:in 'Jekyll::Command.process_with_graceful_fail'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/commands/serve.rb:85:in 'block (2 levels) in Jekyll::Commands::Serve.init_with_program'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary/command.rb:221:in 'block in Mercenary::Command#execute'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary/command.rb:221:in 'Array#each'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary/command.rb:221:in 'Mercenary::Command#execute'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary/program.rb:44:in 'Mercenary::Program#go'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary.rb:21:in 'Mercenary.program'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/exe/jekyll:15:in '<top (required)>'
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/binstub/jekyll:16:in 'Kernel#load'
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/binstub/jekyll:16:in '<main>'

WARN JekyllBadge::JekyllBadge: markup is a TrueClass, not a String
ERROR JekyllSupport::HRefTag: /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:172:in 'JekyllSupport.process_jekyll_variables': undefined method 'each' for an instance of Jekyll::Drops::JekyllDrop (NoMethodError)

    jekyll&.each do |name, value|
          ^^^^^^
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:105:in 'JekyllSupport.lookup_liquid_variables'
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/lib/tag/jekyll_plugin_support_tag.rb:65:in 'JekyllSupport::JekyllTag#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/block_body.rb:103:in 'Liquid::BlockBody#render_node_to_output'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/block_body.rb:91:in 'Liquid::BlockBody#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/template.rb:206:in 'block in Liquid::Template#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/template.rb:240:in 'Liquid::Template#with_profiling'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/template.rb:205:in 'Liquid::Template#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/template.rb:218:in 'Liquid::Template#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:39:in 'block (3 levels) in Jekyll::LiquidRenderer::File#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:59:in 'Jekyll::LiquidRenderer::File#measure_counts'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:38:in 'block (2 levels) in Jekyll::LiquidRenderer::File#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:63:in 'Jekyll::LiquidRenderer::File#measure_bytes'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:37:in 'block in Jekyll::LiquidRenderer::File#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:70:in 'Jekyll::LiquidRenderer::File#measure_time'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:36:in 'Jekyll::LiquidRenderer::File#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/renderer.rb:129:in 'Jekyll::Renderer#render_liquid'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/renderer.rb:80:in 'Jekyll::Renderer#render_document'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/renderer.rb:63:in 'Jekyll::Renderer#run'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:572:in 'Jekyll::Site#render_regenerated'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:557:in 'block (2 levels) in Jekyll::Site#render_docs'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:556:in 'Array#each'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:556:in 'block in Jekyll::Site#render_docs'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:555:in 'Hash#each_value'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:555:in 'Jekyll::Site#render_docs'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:210:in 'Jekyll::Site#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:80:in 'Jekyll::Site#process'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/command.rb:28:in 'Jekyll::Command.process_site'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/commands/build.rb:65:in 'Jekyll::Commands::Build.build'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/commands/build.rb:36:in 'Jekyll::Commands::Build.process'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/command.rb:91:in 'block in Jekyll::Command.process_with_graceful_fail'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/command.rb:91:in 'Array#each'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/command.rb:91:in 'Jekyll::Command.process_with_graceful_fail'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/commands/serve.rb:85:in 'block (2 levels) in Jekyll::Commands::Serve.init_with_program'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary/command.rb:221:in 'block in Mercenary::Command#execute'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary/command.rb:221:in 'Array#each'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary/command.rb:221:in 'Mercenary::Command#execute'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary/program.rb:44:in 'Mercenary::Program#go'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary.rb:21:in 'Mercenary.program'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/exe/jekyll:15:in '<top (required)>'
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/binstub/jekyll:16:in 'Kernel#load'
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/binstub/jekyll:16:in '<main>'

WARN JekyllSupport::HRefTag: markup is a TrueClass, not a String
ERROR ElseNotDraft: /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:172:in 'JekyllSupport.process_jekyll_variables': undefined method 'each' for an instance of Jekyll::Drops::JekyllDrop (NoMethodError)

    jekyll&.each do |name, value|
          ^^^^^^
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:105:in 'JekyllSupport.lookup_liquid_variables'
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/lib/tag/jekyll_plugin_support_tag.rb:65:in 'JekyllSupport::JekyllTag#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/block_body.rb:103:in 'Liquid::BlockBody#render_node_to_output'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/block_body.rb:91:in 'Liquid::BlockBody#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/block.rb:17:in 'Liquid::Block#render'
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/lib/block/jekyll_plugin_support_block.rb:50:in 'JekyllSupport::JekyllBlock#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/block_body.rb:103:in 'Liquid::BlockBody#render_node_to_output'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/block_body.rb:82:in 'Liquid::BlockBody#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/template.rb:206:in 'block in Liquid::Template#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/template.rb:240:in 'Liquid::Template#with_profiling'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/template.rb:205:in 'Liquid::Template#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/template.rb:218:in 'Liquid::Template#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:39:in 'block (3 levels) in Jekyll::LiquidRenderer::File#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:59:in 'Jekyll::LiquidRenderer::File#measure_counts'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:38:in 'block (2 levels) in Jekyll::LiquidRenderer::File#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:63:in 'Jekyll::LiquidRenderer::File#measure_bytes'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:37:in 'block in Jekyll::LiquidRenderer::File#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:70:in 'Jekyll::LiquidRenderer::File#measure_time'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:36:in 'Jekyll::LiquidRenderer::File#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/renderer.rb:129:in 'Jekyll::Renderer#render_liquid'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/renderer.rb:80:in 'Jekyll::Renderer#render_document'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/renderer.rb:63:in 'Jekyll::Renderer#run'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:572:in 'Jekyll::Site#render_regenerated'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:557:in 'block (2 levels) in Jekyll::Site#render_docs'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:556:in 'Array#each'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:556:in 'block in Jekyll::Site#render_docs'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:555:in 'Hash#each_value'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:555:in 'Jekyll::Site#render_docs'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:210:in 'Jekyll::Site#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:80:in 'Jekyll::Site#process'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/command.rb:28:in 'Jekyll::Command.process_site'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/commands/build.rb:65:in 'Jekyll::Commands::Build.build'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/commands/build.rb:36:in 'Jekyll::Commands::Build.process'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/command.rb:91:in 'block in Jekyll::Command.process_with_graceful_fail'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/command.rb:91:in 'Array#each'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/command.rb:91:in 'Jekyll::Command.process_with_graceful_fail'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/commands/serve.rb:85:in 'block (2 levels) in Jekyll::Commands::Serve.init_with_program'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary/command.rb:221:in 'block in Mercenary::Command#execute'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary/command.rb:221:in 'Array#each'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary/command.rb:221:in 'Mercenary::Command#execute'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary/program.rb:44:in 'Mercenary::Program#go'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary.rb:21:in 'Mercenary.program'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/exe/jekyll:15:in '<top (required)>'
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/binstub/jekyll:16:in 'Kernel#load'
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/binstub/jekyll:16:in '<main>'

WARN ElseNotDraft: markup is a TrueClass, not a String
ERROR IfDraft: /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:172:in 'JekyllSupport.process_jekyll_variables': undefined method 'each' for an instance of Jekyll::Drops::JekyllDrop (NoMethodError)

    jekyll&.each do |name, value|
          ^^^^^^
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:105:in 'JekyllSupport.lookup_liquid_variables'
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/lib/block/jekyll_plugin_support_block.rb:72:in 'JekyllSupport::JekyllBlock#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/block_body.rb:103:in 'Liquid::BlockBody#render_node_to_output'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/block_body.rb:82:in 'Liquid::BlockBody#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/template.rb:206:in 'block in Liquid::Template#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/template.rb:240:in 'Liquid::Template#with_profiling'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/template.rb:205:in 'Liquid::Template#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/template.rb:218:in 'Liquid::Template#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:39:in 'block (3 levels) in Jekyll::LiquidRenderer::File#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:59:in 'Jekyll::LiquidRenderer::File#measure_counts'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:38:in 'block (2 levels) in Jekyll::LiquidRenderer::File#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:63:in 'Jekyll::LiquidRenderer::File#measure_bytes'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:37:in 'block in Jekyll::LiquidRenderer::File#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:70:in 'Jekyll::LiquidRenderer::File#measure_time'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:36:in 'Jekyll::LiquidRenderer::File#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/renderer.rb:129:in 'Jekyll::Renderer#render_liquid'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/renderer.rb:80:in 'Jekyll::Renderer#render_document'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/renderer.rb:63:in 'Jekyll::Renderer#run'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:572:in 'Jekyll::Site#render_regenerated'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:557:in 'block (2 levels) in Jekyll::Site#render_docs'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:556:in 'Array#each'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:556:in 'block in Jekyll::Site#render_docs'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:555:in 'Hash#each_value'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:555:in 'Jekyll::Site#render_docs'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:210:in 'Jekyll::Site#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:80:in 'Jekyll::Site#process'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/command.rb:28:in 'Jekyll::Command.process_site'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/commands/build.rb:65:in 'Jekyll::Commands::Build.build'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/commands/build.rb:36:in 'Jekyll::Commands::Build.process'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/command.rb:91:in 'block in Jekyll::Command.process_with_graceful_fail'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/command.rb:91:in 'Array#each'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/command.rb:91:in 'Jekyll::Command.process_with_graceful_fail'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/commands/serve.rb:85:in 'block (2 levels) in Jekyll::Commands::Serve.init_with_program'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary/command.rb:221:in 'block in Mercenary::Command#execute'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary/command.rb:221:in 'Array#each'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary/command.rb:221:in 'Mercenary::Command#execute'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary/program.rb:44:in 'Mercenary::Program#go'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary.rb:21:in 'Mercenary.program'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/exe/jekyll:15:in '<top (required)>'
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/binstub/jekyll:16:in 'Kernel#load'
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/binstub/jekyll:16:in '<main>'

WARN IfDraft: markup is a TrueClass, not a String
ERROR ElseDraft: /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:172:in 'JekyllSupport.process_jekyll_variables': undefined method 'each' for an instance of Jekyll::Drops::JekyllDrop (NoMethodError)

    jekyll&.each do |name, value|
          ^^^^^^
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:105:in 'JekyllSupport.lookup_liquid_variables'
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/lib/tag/jekyll_plugin_support_tag.rb:65:in 'JekyllSupport::JekyllTag#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/block_body.rb:103:in 'Liquid::BlockBody#render_node_to_output'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/block_body.rb:91:in 'Liquid::BlockBody#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/block.rb:17:in 'Liquid::Block#render'
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/lib/block/jekyll_plugin_support_block.rb:50:in 'JekyllSupport::JekyllBlock#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/block_body.rb:103:in 'Liquid::BlockBody#render_node_to_output'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/block_body.rb:82:in 'Liquid::BlockBody#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/template.rb:206:in 'block in Liquid::Template#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/template.rb:240:in 'Liquid::Template#with_profiling'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/template.rb:205:in 'Liquid::Template#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/template.rb:218:in 'Liquid::Template#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:39:in 'block (3 levels) in Jekyll::LiquidRenderer::File#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:59:in 'Jekyll::LiquidRenderer::File#measure_counts'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:38:in 'block (2 levels) in Jekyll::LiquidRenderer::File#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:63:in 'Jekyll::LiquidRenderer::File#measure_bytes'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:37:in 'block in Jekyll::LiquidRenderer::File#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:70:in 'Jekyll::LiquidRenderer::File#measure_time'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/liquid_renderer/file.rb:36:in 'Jekyll::LiquidRenderer::File#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/renderer.rb:129:in 'Jekyll::Renderer#render_liquid'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/renderer.rb:80:in 'Jekyll::Renderer#render_document'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/renderer.rb:63:in 'Jekyll::Renderer#run'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:572:in 'Jekyll::Site#render_regenerated'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:557:in 'block (2 levels) in Jekyll::Site#render_docs'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:556:in 'Array#each'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:556:in 'block in Jekyll::Site#render_docs'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:555:in 'Hash#each_value'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:555:in 'Jekyll::Site#render_docs'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:210:in 'Jekyll::Site#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/site.rb:80:in 'Jekyll::Site#process'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/command.rb:28:in 'Jekyll::Command.process_site'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/commands/build.rb:65:in 'Jekyll::Commands::Build.build'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/commands/build.rb:36:in 'Jekyll::Commands::Build.process'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/command.rb:91:in 'block in Jekyll::Command.process_with_graceful_fail'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/command.rb:91:in 'Array#each'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/command.rb:91:in 'Jekyll::Command.process_with_graceful_fail'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyll/commands/serve.rb:85:in 'block (2 levels) in Jekyll::Commands::Serve.init_with_program'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary/command.rb:221:in 'block in Mercenary::Command#execute'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary/command.rb:221:in 'Array#each'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary/command.rb:221:in 'Mercenary::Command#execute'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary/program.rb:44:in 'Mercenary::Program#go'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/mercenary-0.4.0/lib/mercenary.rb:21:in 'Mercenary.program'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/exe/jekyll:15:in '<top (required)>'
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/binstub/jekyll:16:in 'Kernel#load'
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/binstub/jekyll:16:in '<main>'

WARN ElseDraft: markup is a TrueClass, not a String
ERROR UnlessDraft: /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:172:in 'JekyllSupport.process_jekyll_variables': undefined method 'each' for an instance of Jekyll::Drops::JekyllDrop (NoMethodError)

    jekyll&.each do |name, value|
          ^^^^^^
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/lib/jekyll_plugin_support/jekyll_plugin_support_class.rb:105:in 'JekyllSupport.lookup_liquid_variables'
 from /mnt/f/work/jekyll/my_plugins/jekyll_plugin_support/lib/block/jekyll_plugin_support_block.rb:72:in 'JekyllSupport::JekyllBlock#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/block_body.rb:103:in 'Liquid::BlockBody#render_node_to_output'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/block_body.rb:82:in 'Liquid::BlockBody#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/template.rb:206:in 'block in Liquid::Template#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/template.rb:240:in 'Liquid::Template#with_profiling'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/template.rb:205:in 'Liquid::Template#render'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/liquid-4.0.4/lib/liquid/template.rb:218:in 'Liquid::Template#render!'
 from /home/mslinn/.rbenv/versions/3.4.6/lib/ruby/gems/3.4.0/gems/jekyll-4.4.1/lib/jekyl

```
