require 'spec_helper'
require 'rspec-puppet/support'

# is_expected.to and a_string_starting_with not available with rspec 2.14, which is only used for puppet < 3
if Puppet.version.to_f >= 3.0
  describe RSpec::Puppet::ManifestMatchers::Compile do
    include RSpec::Puppet::Support
    # override RSpec::Puppet::Support's subject with the original default
    subject { RSpec::Puppet::ManifestMatchers::Compile.new }

    let(:catalogue) { lambda { load_catalogue(:host) } }

    describe "a valid manifest" do
      let (:pre_condition) { 'file { "/tmp/resource": }' }

      it ("matches") { is_expected.to be_matches catalogue }
      it do
        is_expected.to have_attributes(
          :description => "compile into a catalogue without dependency cycles"
        )
      end

      context "when expecting an \"example\" error" do
        before(:each) { subject.and_raise_error("example") }

        it ("doesn't match") { is_expected.to_not be_matches catalogue }
        it do
          is_expected.to have_attributes(
            :description => "fail to compile and raise the error \"example\""
          )
        end

        context "after matching" do
          before(:each) { subject.matches? catalogue }

          it do
            is_expected.to have_attributes(
              :failure_message => a_string_starting_with("expected that the catalogue would fail to compile and raise the error \"example\"")
            )
          end
        end
      end

      context "when matching an \"example\" error" do
        before(:each) { subject.and_raise_error(%r{example}) }

        it ("doesn't match") { is_expected.to_not be_matches catalogue }
        it do
          is_expected.to have_attributes(
            :description => "fail to compile and raise an error matching /example/"
          )
        end

        context "after matching" do
          before(:each) { subject.matches? catalogue }

          it do
            is_expected.to have_attributes(
              :failure_message => a_string_starting_with("expected that the catalogue would fail to compile and raise an error matching /example/")
            )
          end
        end
      end
    end

    describe "a manifest with missing dependencies" do
      let (:pre_condition) { 'file { "/tmp/resource": require => File["/tmp/missing"] }' }

      it ("doesn't match") { is_expected.to_not be_matches catalogue }

      context "after matching" do
        before(:each) { subject.matches? catalogue }

        it do
          is_expected.to have_attributes(
            :failure_message => a_string_matching(%r{\Aerror during compilation: Could not (retrieve dependency|find resource) 'File\[/tmp/missing\]'})
          )
        end
      end
    end

    describe "a manifest with syntax error" do
      let (:pre_condition) { 'file { "/tmp/resource": ' }

      it ("doesn't match") { is_expected.to_not be_matches catalogue }

      context "after matching" do
        before(:each) { subject.matches? catalogue }

        it do
          is_expected.to have_attributes(
            :failure_message => a_string_starting_with("error during compilation: ")
          )
        end
      end
    end

    describe "a manifest with a dependency cycle" do
      let (:pre_condition) {
        <<-EOS
          file { "/tmp/a": require => File["/tmp/b"] }
          file { "/tmp/b": require => File["/tmp/a"] }
        EOS
      }

      it ("doesn't match") { is_expected.to_not be_matches catalogue }

      context "after matching" do
        before(:each) { subject.matches? catalogue }

        it do
          is_expected.to have_attributes(
            :failure_message => a_string_starting_with("dependency cycles found: ")
          )
        end
      end

      context "when expecting an \"example\" error" do
        before(:each) { subject.and_raise_error("example") }

        it ("doesn't match") { is_expected.to_not be_matches catalogue }

        context "after matching" do
          before(:each) { subject.matches? catalogue }

          it do
            is_expected.to have_attributes(
              :description => "fail to compile and raise the error \"example\"",
              :failure_message => a_string_starting_with("dependency cycles found: ")
            )
          end
        end
      end

      context "when matching an \"example\" error" do
        before(:each) { subject.and_raise_error(%r{example}) }

        it ("doesn't match") { is_expected.to_not be_matches catalogue }

        context "after matching" do
          before(:each) { subject.matches? catalogue }

          it do
            is_expected.to have_attributes(
              :description => "fail to compile and raise an error matching /example/",
              :failure_message => a_string_starting_with("dependency cycles found: ")
            )
          end
        end
      end
    end

    describe "a manifest with a real failure" do
      let (:pre_condition) { 'fail("failure")' }

      it ("doesn't match") { is_expected.to_not be_matches catalogue }

      context "after matching" do
        before(:each) { subject.matches? catalogue }

        it do
          is_expected.to have_attributes(
            :description => "compile into a catalogue without dependency cycles",
            :failure_message => a_string_starting_with("error during compilation: ")
          )
        end
      end

      context "when expecting the failure" do
        before(:each) { subject.and_raise_error("Evaluation Error: Error while evaluating a Function Call, failure at line 52:1 on node rspec::puppet::manifestmatchers::compile") }

        if Puppet.version.to_f >= 4.0
          # the error message above is puppet4 specific
          it ("matches") { is_expected.to be_matches catalogue }
        end
        it do
          is_expected.to have_attributes(
            :description => "fail to compile and raise the error \"Evaluation Error: Error while evaluating a Function Call, failure at line 52:1 on node rspec::puppet::manifestmatchers::compile\""
          )
        end

        context "after matching" do
          before(:each) { subject.matches? catalogue }

          it do
            is_expected.to have_attributes(
              :failure_message => a_string_starting_with("error during compilation: ")
            )
          end
        end
      end

      context "when matching the failure" do
        before(:each) { subject.and_raise_error(%r{failure}) }

        it ("matches") { is_expected.to be_matches catalogue }
        it do
          is_expected.to have_attributes(
            :description => "fail to compile and raise an error matching /failure/"
          )
        end

        context "after matching" do
          before(:each) { subject.matches? catalogue }

          it do
            is_expected.to have_attributes(
              :failure_message => a_string_starting_with("error during compilation: ")
            )
          end
        end
      end
    end
  end
end
