---
layout: minimal
---

# Changelog

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
