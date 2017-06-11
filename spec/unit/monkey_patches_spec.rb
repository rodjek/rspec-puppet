require 'spec_helper'

# rspec 2.x doesn't have RSpec::Support, so fall back to File::ALT_SEPARATOR to
# detect if running on windows
WINDOWS = defined?(RSpec::Support) ? RSpec::Support::OS.windows? : !!File::ALT_SEPARATOR

describe 'File constants' do
  context 'on windows', :if => WINDOWS do
    specify('File::PATH_SEPARATOR') { expect(File::PATH_SEPARATOR).to eq(';') }
    specify('File::ALT_SEPARATOR') { expect(File::ALT_SEPARATOR).to eq("\\") }
  end

  context 'on posix', :unless => WINDOWS do
    specify('File::PATH_SEPARATOR') { expect(File::PATH_SEPARATOR).to eq(':') }
    specify('File::ALT_SEPARATOR') { expect(File::ALT_SEPARATOR).to be_nil }
  end
end

describe 'Pathname constants' do
  context 'on windows', :if => WINDOWS do
    specify('Pathname::SEPARATOR_PAT') { expect(Pathname::SEPARATOR_PAT).to eq(/[\\\/]/) }
  end

  context 'on linux', :unless => WINDOWS do
    specify('Pathname::SEPARATOR_PAT') { expect(Pathname::SEPARATOR_PAT).to eq(/\//) }
  end
end
