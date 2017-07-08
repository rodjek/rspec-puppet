---
layout: minimal
---

# Changelog

## 2.6.4

### Fixed

 * A regression that prevented environment names to be specified as a symbol.
 * A regression that prevented the `environmentpath` setting from taking
   effect.
 * Stubbed out the automatic confines created by resource providers on their
   specified commands, which was preventing the correct provider from being
   assigned to a resource when performing cross-platform testing.

[View Diff](https://github.com/rodjek/rspec-puppet/compare/v2.6.3...v2.6.4)

## 2.6.3

### Fixed

 * Facts derived from the node name now only get merged on top of the facts
   specified by `RSpec.configuration.default_facts` and `let(:facts)` if the
   node name has been manually specified with `let(:node)`.

[View Diff](https://github.com/rodjek/rspec-puppet/compare/v2.6.2...v2.6.3)

## 2.6.2

### Changed

 * Puppet 5.0.x added to the CI test matrices.
 * The automatic setup code now checks for the presence of `metadata.json` in
   the working directory. If not present, it assumes that rspec-puppet is
   running from inside a control repo instead of a module and skips creating
   the `spec/fixtures` directory structure and link.

### Added

 * A new configuration option has been added
   (`RSpec.configuration.setup_fixtures`) that controls whether rspec-puppet
   will manage the `spec/fixtures` link.

### Fixed

 * A race condition when running rspec-puppet under parallel\_tests causing
   errors when creating the `spec/fixtures` link.
 * The contents of the `networking` fact hash is no longer cleared when merging
   in the facts derived from the node name.

[View Diff](https://github.com/rodjek/rspec-puppet/compare/v2.6.1...v2.6.2)

## 2.6.1

### Fixed

 * 2.6.0 introduced a change to how resource titles are rendered in the test
   manifest which caused them to get rendered as double quoted strings. This
   caused a failure for tests of defined types that contained `$` characters,
   as Puppet would try to interpolate the values in the title as variable(s).

[View Diff](https://github.com/rodjek/rspec-puppet/compare/v2.6.0...v2.6.1)

## 2.6.0

The Windows parity release. rspec-puppet now officially supports Windows. A lot
of work has been put in to support cross-platform tests, so that you can now
test your Windows manifests on \*nix, and your \*nix manifests on Windows.

Huge thanks to all the contributors! And everyone that's been waiting for a new
release!

[View Diff](https://github.com/rodjek/rspec-puppet/compare/v2.5.0...v2.6.0)

### Changed

 * Puppet settings are now applied as application overrides, allowing users to
   call `Puppet.settings` directly to make changes to settings without them
   getting clobbered by rspec-puppet.
 * Improved support for setting up the `spec/fixtures/modules` link on Windows
   by using directory junctions instead of symlinks, removing the need for
   Administrator access.
 * When testing for the absence of a parameter on a resource, the error message
   now contains the value(s) of the parameter(s) that should be undefined.
 * When testing a defined type, the defined type being tested is no longer part
   of the coverage report.
 * The cached catalogue will now be invalidated when hiera-puppet-helper users
   change their `hiera_data` value.
 * Multiple instances of a defined type can now be tested at once by providing
   an array of strings with `let(:title)`.
 * Explicitly specifying the type of an example group (`:type => :class`) now
   takes precedence over the type inferred from the spec file's location.
 * The manifest specified in `RSpec.configuration.manifest` (path to `site.pp`
   for Puppet < 4.x) is now imported if specified on Puppet >= 4.x.
 * Puppet functions called when testing a Puppet function now get executed in
   the same scope as parent function.

### Added

 * The module is now automatically linked into `spec/fixtures/modules` at the
   start of the rspec-puppet run.
 * CI testing of PRs on Windows via Appveyor.
 * Support for setting node parameters (mocking the behaviour of an ENC or
   Puppet Enterprise Console) using `let(:node_params)`.
 * Support for injecting Puppet code at the end of the test code using
   `let(:post_condition)`.
 * Resource coverage reports for `host` specs.
 * Puppet functions that take a lambda as a parameter can now be tested by
   chaining `with_lambda` to the `run` matcher.
 * Facts and trusted facts are now available when testing Puppet functions.
 * Hiera configuration can now be specified when testing Puppet functions using
   `let(:hiera_config)`.
 * Trusted facts (`$trusted[]`) can now be specified in
   `RSpec.configuration.default_trusted_facts` or by `let(:trusted_facts)`.
 * `:default` is now a supported parameter value when passed in by
   `let(:params)`.
 * Support for testing Puppet data type aliases.

### Fixed

 * Facts generated from the node name (as set by `let(:node)`) now take
   precedence over the values specified in `RSpec.configuration.default_facts`
   or by `let(:facts)`.
 * Only fact names will now be converted to lowercase, not the fact values.
 * Matchers now support resources where the namevar has a different value to
   the title.
 * Resources created outside of the module being tested by functions like
   `create_resources` or `ensure_package` are no longer present in the coverage
   report from Puppet 4.6 onwards.
 * Guards have been put in place to prevent the possibility of rspec-puppet
   getting stuck in an infinite recursion when testing the relationships
   between resources.
 * A full `spec/spec_helper.rb` file is now written out by `rspec-puppet-init`
   to fix the `fixture_path` issue on new modules.
 * The namevar of a resources is no longer taken into account when testing the
   exact parameters of the resource with `only_with`.
 * Minimum resource coverage check for RSpec <= 3.2.
 * Resource parameters that take a hash as their value will no longer have that
   hash converted into an array.
 * Testing the value of a parameter with a Proc that returns `nil` now works as
   expected.
 * When testing Puppet functions, the function name is no longer automatically
   coverted to lowercase.
 * The value of `$::environment` is now forced to be a string as expected for
   Puppet 4.0 - 4.3.
 * app\_management is no longer enabled by rspec-puppet for Puppet >= 5.0 as it
   is already enabled by default.
 * Failing to provide parameters when testing an application now raises the
   correct exception (`ArgumentError`).
 * Ruby symbols in nested hashes or arrays are now converted into strings when
   passed in by `let(:params)`.
 * Namespaced resources are now correctly capitalised when being added to the
   resource coverage filter.

## 2.5.0

Headline features are app management, nested hashes in params, and testing for
"internal" functions.

Thanks to everyone who contributed: Leo Arnold, Matt Schuchard, and Si Wilkins.

[View Diff](https://github.com/rodjek/rspec-puppet/compare/v2.4.0...v2.5.0)

### Changed

 * Updates to the README
 * Improved Gemfile to work with older versions of Ruby

### Added

 * Added support for app management testing
 * Added support for nested hashes in params
 * Added support for testing Puppet 4.x "internal" functions
 * Link functions and types into test dir on setup
 * Increased test coverage

## 2.4.0

This release now supports testing exported resources in the same way that
normal resources in the catalogue are tested. Access them in your examples
using `exported_resources`. See "Testing Exported Resources" in the README for
examples.

Thanks to Adrien Thebo, Arthur Gautier, Brett Gray and Nicholas Hinds, as well
as all the folks helping out on github for the contributions to this release.

[View Diff](https://github.com/rodjek/rspec-puppet/compare/v2.3.2...v2.4.0)

### Changed

 * Pulled a lot of the version specific code into separate classes to reduce
   complexity and enable easier maintenance going forward.

### Added

 * Added support for colon separated module_path and environmentpath values
 * Added support for setting a minimum threshold for the code coverage test
 * Added code to reinitialise Puppet before each example in order to ensure
   a consistent test environment.

## 2.3.2

Properly fix yesterday's issue by unsharing the cache key before passing the
data to Puppet. This also contains a new test matrix to avoid missing
a half-baked fix.

[View Diff](https://github.com/rodjek/rspec-puppet/compare/v2.3.1...v2.3.2)

## 2.3.1

A quick workaround to re-enable testing with the recently released Puppet 3.8.5
and the soon to be released Puppet 4.3.2. See PUP-5743 for the gritty details.
Upgrade to this version if you hit the "undefined method \`resource' for
nil:NilClass" error.

[View Diff](https://github.com/rodjek/rspec-puppet/compare/v2.3.0...v2.3.1)

## 2.3.0

rspec-puppet now supports testing custom types, `:undef` values in params,
structured facts, and checks resource dependencies recursively.

The settings in `module_path` and `manifest` are now respected throughout the
code base. The former default for `module_path` (`/etc/puppet/modules`) was
dropped to avoid accidentally poisoning the test environment with unrelated
code.

To reduce the maintenance overhead of boilerplate code, rspec-puppet now
provides some of the code that rspec-puppet-init deployed in helper files that
you can just `require` instead.

This release also reduces memory usage on bigger testsuites drastically by
reducing the caching of compiled catalogues.

Thanks to Adrien Thebo, Alex Harvey, Brian, Dan Bode, Dominic Cleal, Javier
Palacios, Jeff McCune, Jordan Moldow, Peter van Zetten, Raphael Pinson, Simon
Kohlmeyer, and Tristan Colgate for their contibutions to this release.

[View Diff](https://github.com/rodjek/rspec-puppet/compare/v2.2.0...v2.3.0)

### Changed

 * Limit the catalogue cache to 16 entries. Significant memory savings and
   reduced runtime were observed in testing this.
 * Prevent Puppet 3.x \_timestamp fact from invalidating the cache.
 * Extracted catalogue cache from RSpec::Puppet::Support.
 * Updates README to use the rspec 3 expect syntax, and additional
   explanations.
 * `contain_file(...).with_content(...)` will now only show the diff and not
   the full contents of the file.

### Added

 * Custom type testing example group and matcher
 * before/require/subscribe/notify checking now searches recursively through
   all dependencies. `File[a] -> File[b] -> File[c]` is now matched by
   `contain_file('a').that_comes_before('File[c]')`, whereas earlier versions
   would have missed that.
 * Support structured facts with keys as symbols or strings
 * rspec-puppet-init now creates smaller files, using rspec-puppet helpers,
   instead of pasting code into the module.
 * Added a list of related projects to the README.

### Fixed

 * `compile.and_raise_error` now correctly considers successful compilation an
   error.
 * Puppet's `module_path` can now contain multiple entries and rspec-puppet
   will configure Puppet to load code from all of them.
 * Support running with rspec 2.99 again
 * Non-class resources are now covered by the coverage code
 * Autorequires checking doesn't abort on "undefined method \`[]' for
   nil:NilClass"
 * Improved documentation for hiera integration, added example spec
 * Document the `scope` property.

## 2.2.0

[View Diff](https://github.com/rodjek/rspec-puppet/compare/v2.1.0...v2.2.0)

### Added

 * Added setting for ordering, strict\_variables, stringify\_facts, and
   trusted\_node\_data.
 * Exposed the scope in function example groups.

### Fixed

 * rspec-puppet-init now works with Puppet 4
 * Several fixes and enhancements for the `run` matcher
 * Recompile the catalogue when the hiera config changes

## 2.1.0

[View Diff](https://github.com/rodjek/rspec-puppet/compare/v2.0.1...v2.1.0)

### Added

 * Puppet 4 support
 * Ability to set `environment` with a let block
 * Better function failure messages

### Fixed

 * Filter fixtures out of coverage reports
 * Fix functions accidentally modifying rspec function arguments
 * Restructured TravisCI matrix (NB: Puppet 2.6 is no longer tested)

## 2.0.1

[View Diff](https://github.com/rodjek/rspec-puppet/compare/v2.0.0...v2.0.1)

### Fixed

 * Allow RSpec 2 to still be used

## 2.0.0

[View Diff](https://github.com/rodjek/rspec-puppet/compare/v1.0.1...v2.0.0)

### Changed

 * `subject` is now a lambda to enable catching of compilation failures.

### Added

 * Ability to use RSpec 3
 * Hiera integration
 * Coverage reports
 * Ability to test on the future parser
 * Function tests now have access to the catalogue
 * Add array of references support to the relationship matchers

### Fixed

 * Better error messages and handling for parameters (`nil` and friends) and
   dependency cycles

## 1.0.1

 * Fixed bug where under certain circumstances a newline isn't added after the
   user specified `pre_condition`, causing the catalogue compilation to fail.
 * When comparing parameter values, munge the actual value into an array if the
   expected value is an array with a single item.
 * [View Diff](https://github.com/rodjek/rspec-puppet/compare/v1.0.0...v1.0.1)

## 1.0.0

 * Added support for setting `confdir` inside the `RSpec.configure` block
 * Added support for checking if all the dependencies in the graph have been met
 * Added support for passing values to `without_*`
 * Added matcher to count the number of resources in the catalogue of
   a particular type
 * Function matcher now checks if the specified error has been thrown
 * Added `only_with` chain to the `contain_*` matchers to check if the resource
   only has the specified parameters.
 * Manifest matchers (`contain_*`, etc.) are now available when testing
   functions
 * Added support for passing Procs to `with_` and `without_` chains
 * Fixed `.and_return(false)` when testing functions
 * Removed the deprecated `create_resource` matcher
 * Added `compile` matcher to check if the manifest compiles without any
   dependency cycles
 * Improved the Rakefile generated by `rspec-puppet-init`
 * Fixed bug where RSpec fails when passed nil pre\_condition
 * Added heira support
 * Removed the dependency on puppetlabs\_spec\_helper
 * Added implementation agnostic relationship matchers
 * Puppet 3.2.x support
 * Puppet 3.3.x support
 * Improved matching of parameter values, now supports complex data types
 * Fixed bug where RSpec fails when testing a define without specifying
   parameters.
 * Deprecated `include_class` matcher in favour of `contain_class`
 * [View Diff](https://github.com/rodjek/rspec-puppet/compare/v0.1.6...v1.0.0)

## 0.1.6

 * Allow an array of pre\_conditions
 * Fix `object name is a symbol` error when a test on a function fails
 * Puppet 3.1.x support
 * [View Diff](https://github.com/rodjek/rspec-puppet/compare/v0.1.5...v0.1.6)

## 0.1.5

 * Puppet 3.0.x support
 * [View Diff](https://github.com/rodjek/rspec-puppet/compare/v0.1.4...v0.1.5)

## 0.1.4

 * Improved catalogue caching for faster testing on the same compiled catalogue
 * Add support for pre\_condition when testing functions
 * Fix bug when specifying a array with a single value as a parameter
 * [View Diff](https://github.com/rodjek/rspec-puppet/compare/v0.1.3...v0.1.4)

## 0.1.3

 * Add support for testing the catalogue of a node
 * Add Puppet[:config] as a supported option
 * Add rspec-puppet-init helper script
 * Chained methods added to description of contain\_\* matcher
 * Add support for Ruby 1.9.x
 * [View Diff](https://github.com/rodjek/rspec-puppet/compare/v0.1.1...v0.1.3)

## 0.1.1

 * Add 'with' and 'without' chains to the 'contain\_' matcher to support
   testing multiple parameters by supplying a Hash.
 * Add support for passing regular expressions to 'with\_' and 'without\_'
   chains.
 * [View Diff](https://github.com/rodjek/rspec-puppet/compare/v0.1.0...v0.1.1)

## 0.1.0

 * Add support for testing Puppet functions
 * [View Diff](https://github.com/rodjek/rspec-puppet/compare/v0.0.9...v0.1.0)

## 0.0.9

 * Add support for setting custom 'manifestdir', 'manifest' and 'templatedir'
   Puppet config values
 * Provide a default 'domain' fact
 * [View Diff](https://github.com/rodjek/rspec-puppet/compare/v0.0.8...v0.0.9)

## 0.0.8

 * Add support for fact names as Symbols
 * [View Diff](https://github.com/rodjek/rspec-puppet/compare/v0.0.7...v0.0.8)

## 0.0.7

 * Add 'without\_\*' chain to the 'contain\_\*' matcher to test for the absence
   of parameters.
 * [View Diff](https://github.com/rodjek/rspec-puppet/compare/v0.0.6...v0.0.7)

## 0.0.6

 * Remove Faces API call for Puppet 2.7.x
 * Remove quotes from resource references
 * [View Diff](https://github.com/rodjek/rspec-puppet/compare/v0.0.5...v0.0.6)

## 0.0.5

 * Fix 0.0.4 release (incorrect tag pushed for 0.0.4 release)
 * [View Diff](https://github.com/rodjek/rspec-puppet/compare/v0.0.4...v0.0.5)

## 0.0.4

 * DRY up catalogue compilation
 * Add support for 'pre_condition' to allow the specification of external
   dependencies for classes and defines
 * [View Diff](https://github.com/rodjek/rspec-puppet/compare/v0.0.3...v0.0.4)

## 0.0.3

 * Provide default 'hostname' and 'fqdn' facts
 * Change generic resource matcher to support 'contain\_' as well as 'create\_'
 * Support '\_\_' for resources/classes that contain '::'
 * [View Diff](https://github.com/rodjek/rspec-puppet/compare/v0.0.2...v0.0.3)

## 0.0.2

 * Initial release
