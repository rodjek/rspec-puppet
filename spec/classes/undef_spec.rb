# frozen_string_literal: true

require 'spec_helper'

describe 'undef_test' do
  context "with required_attribute => 'some_string'" do
    context 'and defaults_to_undef unspecified' do
      let(:params) { { required_attribute: 'some_string' } }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('undef_test').with(required_attribute: 'some_string') }

      it { is_expected.to contain_class('undef_test').without_defaults_to_undef }

      it 'does not include undef parameters in the parameter count matcher' do
        res = catalogue.resource('Class', 'undef_test').to_hash.dup
        res.delete(:name)
        expect(res.size).to eq(1)

        expect(subject).to contain_class('undef_test').only_with(
          required_attribute: 'some_string',
          defaults_to_undef: nil
        )
      end
    end

    context 'and defaults_to_undef => :undef' do
      let(:params) { { required_attribute: 'some_string', defaults_to_undef: :undef } }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('undef_test').with(required_attribute: 'some_string') }

      it { is_expected.to contain_class('undef_test').without_defaults_to_undef }

      it 'does not include undef parameters in the parameter count matcher' do
        res = catalogue.resource('Class', 'undef_test').to_hash.dup
        res.delete(:name)
        res.size.should eq(1)

        expect(subject).to contain_class('undef_test').only_with(
          required_attribute: 'some_string',
          defaults_to_undef: nil
        )
      end
    end
  end

  context 'with required_attribute => :undef' do
    context 'and defaults_to_undef unspecified' do
      let(:params) { { required_attribute: :undef } }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('undef_test').without_required_attribute }

      it { is_expected.to contain_class('undef_test').without_defaults_to_undef }

      it 'does not include undef parameters in the parameter count matcher' do
        res = catalogue.resource('Class', 'undef_test').to_hash.dup
        res.delete(:name)
        res.size.should eq(0)

        expect(subject).to contain_class('undef_test').only_with(
          required_attribute: nil,
          defaults_to_undef: nil
        )
      end
    end

    context 'and defaults_to_undef => :undef' do
      let(:params) { { required_attribute: :undef, defaults_to_undef: :undef } }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('undef_test').without_required_attribute }

      it { is_expected.to contain_class('undef_test').without_defaults_to_undef }

      it 'does not include undef parameters in the parameter count matcher' do
        res = catalogue.resource('Class', 'undef_test').to_hash.dup
        res.delete(:name)
        expect(res.size).to eq(0)

        expect(subject).to contain_class('undef_test').only_with(
          required_attribute: nil,
          defaults_to_undef: nil
        )
      end
    end
  end
end
