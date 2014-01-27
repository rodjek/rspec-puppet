require 'spec_helper'

describe 'test::compile_error' do
  it 'should provide a useful message when compilation fails' do
    begin
      should compile.with_all_deps
    rescue Exception => e
      e.message.should match(/error during compilation: Parameter managehome failed on User\[foo\]: User provider directoryservice can not manage home directories at/)
    end
  end
end
