require 'spec_helper'

describe 'exported::realise_tags' do
  context 'with no exported resources' do
    it { should_not contain_file('foo') }
    it { should_not contain_file('bar') }
    it { should_not contain_package('baz') }
  end

  context 'with exported resources' do
    let(:exported_resources) do
      {
        'file' => {
          'foo' => {
            :owner => 'root',
            :group => 'root',
          },
          'bar' => {
            :owner => 'daemon',
            :group => 'daemon',
          }
        },
        'package' => {
          'baz' => {
            :ensure => 'present',
          }
        }
      }
    end

    it { should contain_file('foo').with_owner('root').with_group('root') }
    it { should contain_file('bar').with_owner('daemon').with_group('daemon') }
    it { should_not contain_package('baz') }
  end

  context 'with different exported resources' do
    let(:exported_resources) do
      {
        'file' => {
          'foo' => {
            :owner => 'root',
            :group => 'root',
          }
        },
        'package' => {
          'baz' => {
            :ensure => 'present',
          }
        }
      }
    end

    it { should contain_file('foo').with_owner('root').with_group('root') }
    it { should_not contain_file('bar') }
    it { should_not contain_package('baz') }
  end

  context 'with a single exported resource' do
    let(:exported_resources) do
      {
        'package' => {
          'baz' => {
            :ensure => 'present',
          }
        }
      }
    end

    it { should_not contain_file('foo') }
    it { should_not contain_file('bar') }
    it { should_not contain_package('baz') }
  end
end
