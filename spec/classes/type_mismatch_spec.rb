# frozen_string_literal: true

require 'spec_helper'

describe 'type_mismatch' do
  it { is_expected.to compile.with_all_deps }

  it do
    expect(subject).not_to contain_type_mismatch__hash('bug').with_hash(
      'foo' => {
        'bar' => {}
      }
    )
  end

  it do
    expect do
      expect(subject).not_to contain_type_mismatch__hash('bug').with_hash(
        'foo' => {
          'bar' => {}
        }
      )
    end.not_to raise_error
  end
end
