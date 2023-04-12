# frozen_string_literal: true

require 'spec_helper'

# :type should override the type inferred from the file's location in spec/functions/
describe 'test::bare_class', if: RSpec::Version::STRING >= '3', type: :class do
  it { is_expected.to compile.with_all_deps }
end
