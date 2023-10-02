# frozen_string_literal: true

require 'spec_helper'

describe 'undef_test::def' do
  let(:title) { 'some_undef_test' }

  context "with required_attribute => 'some_string'" do
    context 'and defaults_to_undef unspecified' do
      let(:params) { { required_attribute: 'some_string' } }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_undef_test__def('some_undef_test').with(required_attribute: 'some_string') }

      it { is_expected.to contain_undef_test__def('some_undef_test').without_defaults_to_undef }
    end

    context 'and defaults_to_undef => :undef' do
      let(:params) { { required_attribute: 'some_string', defaults_to_undef: :undef } }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_undef_test__def('some_undef_test').with(required_attribute: 'some_string') }

      it { is_expected.to contain_undef_test__def('some_undef_test').without_defaults_to_undef }
    end
  end

  context 'with required_attribute => :undef' do
    context 'and defaults_to_undef unspecified' do
      let(:params) { { required_attribute: :undef } }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_undef_test__def('some_undef_test').without_required_attribute }

      it { is_expected.to contain_undef_test__def('some_undef_test').without_defaults_to_undef }
    end

    context 'and defaults_to_undef => :undef' do
      let(:params) { { required_attribute: :undef, defaults_to_undef: :undef } }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_undef_test__def('some_undef_test').without_required_attribute }

      it { is_expected.to contain_undef_test__def('some_undef_test').without_defaults_to_undef }
    end
  end
end
