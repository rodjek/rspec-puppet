---
layout: base
title: Change Log
icon: fa fa-history
---

## 2.7.10

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.7.8...v2.7.10"
class="btn btn-primary btn-inline pull-right">View Diff</a>

### Fixed
 * Fix issues with removal of `default_env` method in Puppet 6.17.0.

## 2.7.9

This release had unintended breaking changes and was withdrawn.

## 2.7.8

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.7.7...v2.7.8"
class="btn btn-primary btn-inline pull-right">View Diff</a>

### Fixed
 * Fix cross-platform testing for Puppet >= 6.9.0 when there is no `ipaddress6`
   fact defined.

## 2.7.7

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.7.6...v2.7.7"
class="btn btn-primary btn-inline pull-right">View Diff</a>

### Fixed
 * Fix the support for rspec-expectations >= 3.8.5.

### Changed
 * Remove the rspec-expectations dependency limit introduced in 2.7.6.

## 2.7.6

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.7.5...v2.7.6"
class="btn btn-primary btn-inline pull-right">View Diff</a>

### Changed
 * Limit rspec-expectations dependency to < 3.8.5 due to an incompatible
   change.

## 2.7.5

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.7.4...v2.7.5"
class="btn btn-primary btn-inline pull-right">View Diff</a>

### Fixed
 * Minor refactor to prevent the fix introduced in 2.7.4 from raising
   a deprecation warning on latest RSpec.

## 2.7.4

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.7.3...v2.7.4"
class="btn btn-primary btn-inline pull-right">View Diff</a>

### Fixed
 * Fix the resource coverage test so that rspec will exit non-zero if the
   desired coverage is not met.

## 2.7.3

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.7.2...v2.7.3"
class="btn btn-primary btn-inline pull-right">View Diff</a>

### Fixed
 * Puppet 6 deferred functions are now evaluated and resolved as part of the
   catalogue compilation process.
 * If running with parallel\_tests, the resources that are filtered out of the
   resource coverage report are now taken into account when merging the final
   report, fixing false negative results that can occur.

## 2.7.2

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.7.1...v2.7.2"
class="btn btn-primary btn-inline pull-right">View Diff</a>

### Changed
 * Reverted the change introduced in 2.7.0 that reencoded resource parameter
   values to modify their line endings.

## 2.7.1

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.7.0...v2.7.1"
class="btn btn-primary btn-inline pull-right">View Diff</a>

### Fixed
 * Fixed a bug that prevented the platform pretending/stubbing logic from being
   temporarily disabled when loading Ruby code.

## 2.7.0

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.6.15...v2.7.0"
class="btn btn-primary btn-inline pull-right">View Diff</a>

### Changed
 * Official Puppet 6 support added.
 * When testing resource parameter values, the values received from Puppet are
   now reencoded before testing to ensure that the line endings (if present)
   match the platform being tested.
 * `vendormoduledir` and `basemodulepath` settings (introduced in Puppet 6) are
   now configurable in rspec-puppet.

## 2.6.15

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.6.14...v2.6.15"
class="btn btn-primary btn-inline pull-right">View Diff</a>

### Fixed

 * Added a Puppet 6.x adapter so that rspec-puppet does not try to set removed
   Puppet settings (specifically `trusted_server_facts`) when running tests
   against the upcoming Puppet 6.0.0 release.

## 2.6.14

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.6.13...v2.6.14"
class="btn btn-primary btn-inline pull-right">View Diff</a>

### Fixed

 * If present, `Win32::Dir` will be used to managed the fixtures directory
   junction on Windows as the builtin `File` module does not have complete
   support for directory junctions on Ruby <= 2.1.

### Changed

 * Resource coverage results are now exposed to the configured RSpec reporter
   rather than only being printed to STDOUT.
 * If running with parallel\_tests, resource coverage data is stored in
   per-process temp files and merged at the end of the final rspec process,
   allowing for a complete coverage report to be generated when splitting
   a test suite across multiple rspec processes.

## 2.6.13

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.6.12...v2.6.13"
class="btn btn-primary btn-inline pull-right">View Diff</a>

### Fixed

 * rspec-puppet no longer attempts to set the `trusted_server_facts` Puppet
   setting on Puppet 4.0.0, as the setting was only introduced in Puppet 4.1.0.
 * Automatic `Selinux` stubbing introduced in 2.6.12 no longer assumes the use
   of rspec-mocks. If rspec-mocks is not available, it will fall back to mocha
   and finally fall back to doing nothing if neither is available.

## 2.6.12

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.6.11...v2.6.12"
class="btn btn-primary btn-inline pull-right">View Diff</a>

### Fixed

 * Updated `Win32::TaskScheduler` stubs to match the latest release of
   `win32-taskscheduler`.
 * The `os` structured fact is now correctly treated as a Hash when determining
   the platform that rspec-puppet pretends to be.
 * The default resources that Puppet adds to the catalogue (`Class[main]`,
   `Class[Settings]`, etc) are now filtered out of the catalogue when using the
   `have_resource_count` matcher, rather than simply subtracted from the
   resource count. This allows the `have_resource_count` matcher to be used on
   subsects of the catalogue (`exported_resources` for example).
 * When running on Windows, rspec-puppet will now convert Puppet configuration
   settings from `/dev/null` to `NUL`, preventing Puppet from automatically
   creating directories like `C:\dev` when running tests on Windows as an
   Administrator.
 * When overriding fact values, rspec-puppet will now assign the stub facts
   a weight of 1000 to ensure that they override the generated fact values from
   Facter 3.x.
 * `Selinux.is_selinux_enabled` is now automatically stubbed to return 0 to
   disable any SELinux related apply-time validation of resources.
 * When testing against Puppet 3.x, rspec-puppet will now honour the
   `RSpec.configuration.parser` value when determining the module name to set
   up the fixture symlink.
 * When testing for the absence of a parameter using `only_with(:parameter_name
   => nil`), this will no longer incorrectly affect the expected parameter
   count.

## 2.6.11

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.6.10...v2.6.11"
class="btn btn-primary btn-inline pull-right">View Diff</a>

### Fixed

 * The `server_facts` hash is now only built if
   `RSpec.configuration.trusted_server_facts` is `true`. Previously, this was
   always built but only used when enabled.

## 2.6.10

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.6.9...v2.6.10"
class="btn btn-primary btn-inline pull-right">View Diff</a>

### Fixed

 * Replaced deprecated `File.exists?` calls in `rspec-puppet-init` with
   `File.exist?`, which behaves much more reliably in respect to symlinks.
 * Stubbed out `Puppet::Util::Windows::Security.supports_acl?` when compiling
   the catalogue as this check only make sense when applying the resources to
   a host and prevents testing Windows File resources on non-Windows hosts.
 * The cached default provider for native types is now reset before compiling
   a new catalogue.
 * Resource titles that contain single quotes are now rendered correctly,
   allowing them to be tested.
 * When pretending to be a different platform, the methods in
   `Puppet::Util::Platform` are now stubbed after the catalogue has been
   compiled, allowing path related logic in custom facts to behave as expected.
 * A mock version of `Win32::TaskScheduler` has been added to rspec-puppet.
   This will be loaded when running rspec-puppet on a non-Windows host in order
   to allow testing of catalogues containing Scheduled\_task resources.
 * Stubbed out the `manages_symlinks` feature on
   `Puppet::Type::File::ProviderWindows` as this can only be evaluated at apply
   time and prevents testing Windows File resources that manage symlinks on
   non-Windows hosts.
 * Fixed unhandled exception when testing resource parameters where the
   expected value is an Array or a Hash and the actual value is a different
   data type.
 * A mock version of `Win32::Registry` has been added to rspec-puppet. This
   will be loaded when running rspec-puppet on a non-Windows host in order to
   allow testing of catalogues that contain Exec resources that use the
   `powershell` provider from the `puppetlabs/puppetlabs-powershell` module.
 * Fixed a case where the order in which tests are run can cause a resource
   that is being tested to be falsely reported as untested in the coverage
   report.

### Changed

 * The tests for the `compile` matcher have been updated to support the new
   error message format introduced in Puppet 5.3.4.
 * The builtin `$server_facts` hash is now populated on versions of Puppet that
   support it (Puppet >= 4.3). This is not currently enabled by default, but
   can be enabled by setting `RSpec.configuration.trusted_server_facts` to
   `true`.
 * `$facts['os']['family']` and `$facts['os']['name']` are now checked when
   determining if rspec-puppet needs to pretend to be running on a different
   platform (previously only `$facts['operatingsystem']` and
   `$facts['osfamily']` were used).

## 2.6.9

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.6.8...v2.6.9"
class="btn btn-primary btn-inline pull-right">View Diff</a>

### Fixed

 * Initialise Hiera 3 before loading any monkey patches to ensure that the
   correct code is loaded for the actual platform running the tests.

## 2.6.8

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.6.7...v2.6.8"
class="btn btn-primary btn-inline pull-right">View Diff</a>

### Fixed

 * Performance regression with Puppet < 4.0.0 due to overly agressive cache
   invalidation.
 * Clarified rspec-puppet-init output when run inside a directory that does not
   contain a `metadata.json` file.

## 2.6.7

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.6.6...v2.6.7"
class="btn btn-primary btn-inline pull-right">View Diff</a>

### Fixed

 * An issue where the optional minimum resource coverage check would throw an
   exception when the coverage wasn't 100%.

## 2.6.6

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.6.5...v2.6.6"
class="btn btn-primary btn-inline pull-right">View Diff</a>

### Fixed

 * Fixed an issue caused by `Puppet::Util.get_env` when pretending to be a
   Windows host.

## 2.6.5

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.6.4...v2.6.5"
class="btn btn-primary btn-inline pull-right">View Diff</a>

### Changed

 * `derive_node_facts_from_nodename` setting added to disable the overriding of
   `fqdn`, `hostname`, and `domain` facts with values derived from the node
   name specified with `let(:node)`.

### Fixed

 * The `trusted_facts` hash now accepts symbol keys, matching the behaviour of
   the `facts` hash.
 * The modifications made to Puppet internals are now contained to rspec-puppet
   examples, preventing them from bleeding out into other examples in the same
   RSpec process (like Ruby unit tests).
 * rspec-puppet no longer attempts to configure settings for Puppet 3.x
   releases that they do not support.

## 2.6.4

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.6.3...v2.6.4"
class="btn btn-primary btn-inline pull-right">View Diff</a>

### Fixed

 * A regression that prevented environment names to be specified as a symbol.
 * A regression that prevented the `environmentpath` setting from taking
   effect.
 * Stubbed out the automatic confines created by resource providers on their
   specified commands, which was preventing the correct provider from being
   assigned to a resource when performing cross-platform testing.

## 2.6.3

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.6.2...v2.6.3"
class="btn btn-primary btn-inline pull-right">View Diff</a>

### Fixed

 * Facts derived from the node name now only get merged on top of the facts
   specified by `RSpec.configuration.default_facts` and `let(:facts)` if the
   node name has been manually specified with `let(:node)`.

## 2.6.2

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.6.1...v2.6.2"
class="btn btn-primary btn-inline pull-right">View Diff</a>

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

## 2.6.1

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.6.0...v2.6.1"
class="btn btn-primary btn-inline pull-right">View Diff</a>

### Fixed

 * 2.6.0 introduced a change to how resource titles are rendered in the test
   manifest which caused them to get rendered as double quoted strings. This
   caused a failure for tests of defined types that contained `$` characters
   as Puppet would try and interpolate the values in the title as variable(s).

## 2.6.0

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.5.0...v2.6.0"
class="btn btn-primary btn-inline pull-right">View Diff</a>

The Windows parity release. rspec-puppet now officially supports Windows. A lot
of work has been put in to support cross-platform tests, so that you can now
test your Windows manifests on \*nix, and your \*nix manifests on Windows.

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

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.4.0...v2.5.0"
class="btn btn-primary btn-inline pull-right">View Diff</a>

Headline features are app management, nested hashes in params, and testing for
"internal" functions.

Thanks to everyone who contributed: Leo Arnold, Matt Schuchard, and Si Wilkins.

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

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.3.0...v2.4.0"
class="btn btn-primary btn-inline pull-right">View Diff</a>

This release now supports testing exported resources in the same way that
normal resources in the catalogue are tested. Access them in your examples
using `exported_resources`. See "Testing Exported Resources" in the README for
examples.

Thanks to Adrien Thebo, Arthur Gautier, Brett Gray and Nicholas Hinds, as well
as all the folks helping out on github for the contributions to this release.

### Changed
 * Pulled a lot of the version specific code into separate classes to reduce
   complexity and enable easier maintenance going forward.

### Added
 * Added support for colon separated module\_path and environmentpath values
 * Added support for setting a minimum threshold for the code coverage test
 * Added code to reinitialise Puppet before each example in order to ensure
   a consistent test environment.

## 2.3.2

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.3.1...v2.3.2"
class="btn btn-primary btn-inline pull-right">View Diff</a>

Properly fix yesterday's issue by unsharing the cache key before passing the
data to Puppet. This also contains a new test matrix to avoid missing
a half-baked fix.


## 2.3.1

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.3.0...v2.3.1"
class="btn btn-primary btn-inline pull-right">View Diff</a>

A quick workaround to re-enable testing with the recently released Puppet 3.8.5
and the soon to be released Puppet 4.3.2. See PUP-5743 for the gritty details.
Upgrade to this version if you hit the "undefined method \`resource' for
nil:NilClass" error.

## 2.3.0

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.2.0...v2.3.0"
class="btn btn-primary btn-inline pull-right">View Diff</a>

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

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.1.0...v2.2.0"
class="btn btn-primary btn-inline pull-right">View Diff</a>

### Added
 * Added setting for ordering, strict\_variables, stringify\_facts, and
   trusted\_node\_data.
 * Exposed the scope in function example groups.

### Fixed
 * rspec-puppet-init now works with Puppet 4
 * Several fixes and enhancements for the `run` matcher
 * Recompile the catalogue when the hiera config changes

## 2.1.0

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.0.1...v2.1.0"
class="btn btn-primary btn-inline pull-right">View Diff</a>

### Added
 * Puppet 4 support
 * Ability to set `environment` with a let block
 * Better function failure messages

### Fixed
 * Filter fixtures out of coverage reports
 * Fix functions accidentally modifying rspec function arguments
 * Restructured TravisCI matrix (NB: Puppet 2.6 is no longer tested)

## 2.0.1

<a href="https://github.com/rodjek/rspec-puppet/compare/v2.0.0...v2.0.1"
class="btn btn-primary btn-inline pull-right">View Diff</a>

### Fixed
 * Allow RSpec 2 to still be used

## 2.0.0

<a href="https://github.com/rodjek/rspec-puppet/compare/v1.0.1...v2.0.0"
class="btn btn-primary btn-inline pull-right">View Diff</a>

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

<a href="https://github.com/rodjek/rspec-puppet/compare/v1.0.0...v1.0.1"
class="btn btn-primary btn-inline pull-right">View Diff</a>

 * Fixed bug where under certain circumstances a newline isn't added after the
   user specified `pre_condition`, causing the catalogue compilation to fail.
 * When comparing parameter values, munge the actual value into an array if the
   expected value is an array with a single item.

## 1.0.0

<a href="https://github.com/rodjek/rspec-puppet/compare/v0.1.6...v1.0.0"
class="btn btn-primary btn-inline pull-right">View Diff</a>

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

## 0.1.6

<a href="https://github.com/rodjek/rspec-puppet/compare/v0.1.5...v0.1.6"
class="btn btn-primary btn-inline pull-right">View Diff</a>

 * Allow an array of pre\_conditions
 * Fix `object name is a symbol` error when a test on a function fails
 * Puppet 3.1.x support

## 0.1.5

<a href="https://github.com/rodjek/rspec-puppet/compare/v0.1.4...v0.1.5"
class="btn btn-primary btn-inline pull-right">View Diff</a>

 * Puppet 3.0.x support

## 0.1.4

<a href="https://github.com/rodjek/rspec-puppet/compare/v0.1.3...v0.1.4"
class="btn btn-primary btn-inline pull-right">View Diff</a>

 * Improved catalogue caching for faster testing on the same compiled catalogue
 * Add support for pre\_condition when testing functions
 * Fix bug when specifying a array with a single value as a parameter

## 0.1.3

<a href="https://github.com/rodjek/rspec-puppet/compare/v0.1.1...v0.1.3"
class="btn btn-primary btn-inline pull-right">View Diff</a>

 * Add support for testing the catalogue of a node
 * Add Puppet[:config] as a supported option
 * Add rspec-puppet-init helper script
 * Chained methods added to description of contain\_\* matcher
 * Add support for Ruby 1.9.x

## 0.1.1

<a href="https://github.com/rodjek/rspec-puppet/compare/v0.1.0...v0.1.1"
class="btn btn-primary btn-inline pull-right">View Diff</a>

 * Add 'with' and 'without' chains to the 'contain\_' matcher to support
   testing multiple parameters by supplying a Hash.
 * Add support for passing regular expressions to 'with\_' and 'without\_'
   chains.

## 0.1.0

<a href="https://github.com/rodjek/rspec-puppet/compare/v0.0.9...v0.1.0"
class="btn btn-primary btn-inline pull-right">View Diff</a>

* Add support for testing Puppet functions

## 0.0.9

<a href="https://github.com/rodjek/rspec-puppet/compare/v0.0.8...v0.0.9"
class="btn btn-primary btn-inline pull-right">View Diff</a>

 * Add support for setting custom 'manifestdir', 'manifest' and 'templatedir'
   Puppet config values
 * Provide a default 'domain' fact

## 0.0.8

<a href="https://github.com/rodjek/rspec-puppet/compare/v0.0.7...v0.0.8"
class="btn btn-primary btn-inline pull-right">View Diff</a>

 * Add support for fact names as Symbols

## 0.0.7

<a href="https://github.com/rodjek/rspec-puppet/compare/v0.0.6...v0.0.7"
class="btn btn-primary btn-inline pull-right">View Diff</a>

 * Add 'without\_\*' chain to the 'contain\_\*' matcher to test for the absence
   of parameters.

## 0.0.6

<a href="https://github.com/rodjek/rspec-puppet/compare/v0.0.7...v0.0.6"
class="btn btn-primary btn-inline pull-right">View Diff</a>

 * Remove Faces API call for Puppet 2.7.x
 * Remove quotes from resource references


## 0.0.5

<a href="https://github.com/rodjek/rspec-puppet/compare/v0.0.4...v0.0.5"
class="btn btn-primary btn-inline pull-right">View Diff</a>

 * Fix 0.0.4 release (incorrect tag pushed for 0.0.4 release)

## 0.0.4

<a href="https://github.com/rodjek/rspec-puppet/compare/v0.0.3...v0.0.4"
class="btn btn-primary btn-inline pull-right">View Diff</a>

 * DRY up catalogue compilation
 * Add support for 'pre_condition' to allow the specification of external
   dependencies for classes and defines

## 0.0.3

<a href="https://github.com/rodjek/rspec-puppet/compare/v0.0.2...v0.0.3"
class="btn btn-primary btn-inline pull-right">View Diff</a>

 * Provide default 'hostname' and 'fqdn' facts
 * Change generic resource matcher to support 'contain\_' as well as 'create\_'
 * Support '\_\_' for resources/classes that contain '::'

## 0.0.2

 * Initial release
