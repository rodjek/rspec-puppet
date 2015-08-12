# Change Log
All notable changes to this project will be documented in this file. This
project adheres to [Semantic Versioning](http://semver.org/).

## Unreleased
### Fixed
- Support structured facts with keys as symbols or strings

## [2.3.0]
### Added
- Custom type testing example group and matcher

### Fixed
- Fix #276: `compile.and_raise_error` now correctly considers successful compilation an error
- Puppet's `modulepath` can now contain multiple entries and rspec-puppet will configure puppet to load code from all of them
- `contain_file(...).with_content(...)` will now only show the diff and not the full contents of the file
- improved documentation for hiera integration, added example spec
- document the `scope` property
- unbreak rspec 2.99 support

## [2.2.0]
### Added
- Settings for ordering, strict_variables, stringify_facts, and trusted_node_data
- Expose the scope in function example groups

### Fixed
- rspec-puppet-init now works with Puppet 4
- Several fixes and enhancements for the `run` matcher
- Recompile the catalog when the hiera config changes

## [2.1.0] - 2015-04-21
### Added
- Puppet 4 support
- Ability to set `environment` in a let block
- Better function failure messages

### Fixed
- Filter fixtures from coverage reports
- Fix functions accidentally modifying rspec function arguments
- Restructured TravisCI matrix (NB: Puppet 2.6 is no longer tested)

## [2.0.1] - 2015-03-12
### Fixed
- Allow RSpec 2 to still be used

## [2.0.0] - 2014-12-02
### Changed
- `subject` is now a lambda to enable catching compilation failures.

### Added
- Ability to use RSpec 3
- Hiera integration
- Coverage reports
- Ability to test on the future parser
- Function tests now have a catalogue
- Add array of references support to Relationship matchers `that_requires`,
  `that_comes_before`, `that_notifies`, and `that_subscribes_to`

### Fixed
- Better error messaging and handling for parameters (`nil` and friends) and
  dependency cycles

## 1.0.1 and earlier
For changelog of versions 1.0.1 and earlier, see http://rspec-puppet.com/changelog/

[2.x]: https://github.com/rodjek/rspec-puppet/compare/v2.2.0...master
[2.2.0]: https://github.com/rodjek/rspec-puppet/compare/v2.1.0...v2.2.0
[2.1.0]: https://github.com/rodjek/rspec-puppet/compare/v2.0.1...v2.1.0
[2.0.1]: https://github.com/rodjek/rspec-puppet/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/rodjek/rspec-puppet/compare/v1.0.1...v2.0.0
