# frozen_string_literal: true

require 'spec_helper'

describe 'test::user' do
  it {
    expect(subject).to contain_user('luke').only_with({
                                                        'ensure' => 'present',
                                                        'uid' => '501'
                                                      })
  }
end
