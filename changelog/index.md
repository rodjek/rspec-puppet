---
layout: minimal
---

# Changelog

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
