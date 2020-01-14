require 'spec_helper'

# TODO:
#   * Disable resource coverage test if only testing plans
#   * Decide how to handle multiple apply blocks in a plan as the apply
#     blocks as essentially anonymous when it comes to targetting tests
#     (evaluate sequentially maybe?) e.g.
#     ```
#     plan foo(TargetSpec $nodes) {
#       apply($nodes) {
#         notify { 'foo': }
#       }
#       apply($nodes) {
#         notify { 'bar': }
#       }
#     }
#     ```

describe 'bolt::apply_test' do
  let(:params) { { 'nodes' => 'foo' } }

  before { allow_apply }

  it { is_expected.to be_ok }

  it do
    subject # TODO: Subject caching to avoid having to reevaluate the plan for each example

    expect(apply('foo')).to satisfy do |catalogue|
      extend RSpec::Puppet::ManifestMatchers
      expect(catalogue).to contain_notify('foo')
      expect(catalogue).not_to contain_service('bar')
    end
  end

  # Possible DSL sketches
  #
  # it do
  #   expect(apply('foo')).to apply_resources do
  #     is_expected.to contain_notify('foo')
  #   end
  # end
end
