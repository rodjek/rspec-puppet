# frozen_string_literal: true

require 'spec_helper'

describe 'File constants' do
  context 'on windows', if: windows? do
    specify('File::PATH_SEPARATOR') { expect(File::PATH_SEPARATOR).to eq(';') }
    specify('File::ALT_SEPARATOR') { expect(File::ALT_SEPARATOR).to eq('\\') }
  end

  context 'on non-windows', unless: windows? do
    specify('File::PATH_SEPARATOR') { expect(File::PATH_SEPARATOR).to eq(':') }
    specify('File::ALT_SEPARATOR') { expect(File::ALT_SEPARATOR).to be_nil }
  end
end

describe 'Pathname constants' do
  context 'on windows', if: windows? do
    specify('Pathname::SEPARATOR_PAT') { expect(Pathname::SEPARATOR_PAT.to_s).to eq(%r{[\\/]}.to_s) }
  end

  context 'on non-windows', unless: windows? do
    specify('Pathname::SEPARATOR_PAT') { expect(Pathname::SEPARATOR_PAT.to_s).to eq(%r{/}.to_s) }
  end
end

# These specs taken from the official ruby spec for File.basename
describe 'Pathname#rspec_puppet_basename' do
  subject { Pathname.new('test') }

  it 'is not enabled by default' do
    test_pathname = Pathname.new('test')
    expect(test_pathname).not_to receive(:rspec_puppet_basename).with(anything)
    test_pathname.absolute?
  end

  context 'when enabled' do
    before do
      RSpec.configuration.enable_pathname_stubbing = true
    end

    it 'returns the basename of a path (basic cases)' do
      expect(subject.rspec_puppet_basename('/Some/path/to/test.txt')).to eq('test.txt')
      expect(subject.rspec_puppet_basename(File.join('/tmp'))).to eq('tmp')
      expect(subject.rspec_puppet_basename(File.join(*%w[g f d s a b]))).to eq('b')
      expect(subject.rspec_puppet_basename(File.join('/tmp/'))).to eq('tmp')
      expect(subject.rspec_puppet_basename('/')).to eq('/')
      expect(subject.rspec_puppet_basename('//')).to eq('/')
      expect(subject.rspec_puppet_basename('dir///base///')).to eq('base')
      expect(subject.rspec_puppet_basename('dir///base')).to eq('base')
    end

    it 'returns the last component of the filename' do
      expect(subject.rspec_puppet_basename('a')).to eq('a')
      expect(subject.rspec_puppet_basename('/a')).to eq('a')
      expect(subject.rspec_puppet_basename('/a/b')).to eq('b')
      expect(subject.rspec_puppet_basename('/ab/ba/bag')).to eq('bag')
      expect(subject.rspec_puppet_basename('/ab/ba/bag.txt')).to eq('bag.txt')
      expect(subject.rspec_puppet_basename('/')).to eq('/')
    end

    it 'returns a string' do
      expect(subject.rspec_puppet_basename('foo')).to be_a(String)
    end

    it 'returns the basename for unix format' do
      expect(subject.rspec_puppet_basename('/foo/bar')).to eq('bar')
      expect(subject.rspec_puppet_basename('/foo/bar.txt')).to eq('bar.txt')
      expect(subject.rspec_puppet_basename('bar.c')).to eq('bar.c')
      expect(subject.rspec_puppet_basename('/bar')).to eq('bar')
      expect(subject.rspec_puppet_basename('/bar/')).to eq('bar')
    end

    it 'returns the basename for edgecases' do
      expect(subject.rspec_puppet_basename('')).to eq('')
      expect(subject.rspec_puppet_basename('.')).to eq('.')
      expect(subject.rspec_puppet_basename('..')).to eq('..')
    end

    context 'on posix' do
      before do
        stub_const('Pathname::SEPARATOR_PAT', %r{/})
      end

      it 'returns the basename for edgecases' do
        expect(subject.rspec_puppet_basename('//foo/')).to eq('foo')
        expect(subject.rspec_puppet_basename('//foo//')).to eq('foo')
      end

      it 'takes into consideration the platform path separators' do
        expect(subject.rspec_puppet_basename('c:\\foo\\bar')).to eq('c:\\foo\\bar')
        expect(subject.rspec_puppet_basename('c:/foo/bar')).to eq('bar')
        expect(subject.rspec_puppet_basename('/foo/bar\\baz')).to eq('bar\\baz')
      end
    end

    context 'on windows' do
      before do
        stub_const('Pathname::SEPARATOR_PAT', %r{[\\/]})
      end

      it 'handles UNC pathnames' do
        expect(subject.rspec_puppet_basename('baz//foo')).to eq('foo')
        expect(subject.rspec_puppet_basename('//foo/bar/baz')).to eq('baz')
        expect(subject.rspec_puppet_basename('\\\\foo\\bar\\baz.txt')).to eq('baz.txt')
        expect(subject.rspec_puppet_basename('\\\\foo\\bar\\baz')).to eq('baz')
      end

      it 'takes into consideration the platform path separators' do
        expect(subject.rspec_puppet_basename('C:\\foo\\bar')).to eq('bar')
        expect(subject.rspec_puppet_basename('C:/foo/bar')).to eq('bar')
        expect(subject.rspec_puppet_basename('/foo/bar\\baz')).to eq('baz')
      end

      it 'returns the basename for windows' do
        expect(subject.rspec_puppet_basename('C:\\foo\\bar\\baz.txt')).to eq('baz.txt')
        expect(subject.rspec_puppet_basename('C:\\foo\\bar')).to eq('bar')
        expect(subject.rspec_puppet_basename('C:\\foo\\bar\\')).to eq('bar')
        expect(subject.rspec_puppet_basename('C:\\foo')).to eq('foo')
        expect(subject.rspec_puppet_basename('C:\\')).to eq('\\')
      end

      it 'returns the basename for windows with forward slash' do
        expect(subject.rspec_puppet_basename('C:/')).to eq('/')
        expect(subject.rspec_puppet_basename('C:/foo')).to eq('foo')
        expect(subject.rspec_puppet_basename('C:/foo/bar')).to eq('bar')
        expect(subject.rspec_puppet_basename('C:/foo/bar/')).to eq('bar')
        expect(subject.rspec_puppet_basename('C:/foo/bar//')).to eq('bar')
      end
    end
  end
end

describe 'Puppet::Module#match_manifests' do
  subject do
    Puppet::Module.new(
      'escape',
      File.join(RSpec.configuration.module_path, 'escape'),
      'production'
    )
  end

  it 'returns init.pp for top level class' do
    expect(subject.match_manifests(nil).length).to eq(1)
    expect(subject.match_manifests(nil)[0]).to match(/init\.pp$/)
  end

  it 'returns init.pp for escape::unknown' do
    expect(subject.match_manifests('unknown').length).to eq(1)
    expect(subject.match_manifests('unknown')[0]).to match(/init\.pp$/)
  end

  it 'returns just def.pp for escape::def' do
    expect(subject.match_manifests('def').length).to eq(1)
    expect(subject.match_manifests('def')[0]).to match(/def\.pp$/)
  end
end
