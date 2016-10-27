require 'spec_helper'
require 'rspec-puppet/coverage'
require 'rspec-puppet/support'

describe RSpec::Puppet::Coverage do

  subject { described_class.new }

  # Save and restore the global coverage object so that these tests don't
  # affect the actual spec coverage
  before(:all) do
    @saved = described_class.instance
    described_class.instance = described_class.new
  end

  after(:all) do
    described_class.instance = @saved
  end

  describe "filtering" do
    it "filters boilerplate catalog resources by default" do
      expect(subject.filters).to eq %w[Stage[main] Class[Settings] Class[main]]
    end

    it "can add additional filters" do
      subject.add_filter("notify", "ignore me")
      expect(subject.filters).to include("Notify[ignore me]")

      subject.add_filter("foo::bar", "ignore me")
      expect(subject.filters).to include("Foo::Bar[ignore me]")

      subject.add_filter("class", "foo::bar")
      expect(subject.filters).to include("Class[Foo::Bar]")
    end

    it "filters resources based on the resource title" do
      # TODO: this is evil and uses duck typing on `#to_s` to work.
      fake_resource = "Stage[main]"
      expect(subject.filtered?(fake_resource)).to be
    end
  end

  describe "adding resources that could be covered" do
    it "adds resources that don't exist and aren't filtered" do
      expect(subject.add("Notify[Add me]")).to be
    end

    it "ignores resources that have been filtered" do
      subject.add_filter("notify", "ignore me")
      expect(subject.add("Notify[ignore me]")).to_not be

      subject.add_filter("foo::bar", "ignore me")
      expect(subject.add("Foo::Bar[ignore me]")).to_not be

      subject.add_filter("class", "foo::bar")
      expect(subject.add("Class[Foo::Bar]")).to_not be
    end

    it "ignores resources that have already been added" do
      subject.add("Notify[Ignore the duplicate]")
      expect(subject.add("Notify[Ignore the duplicate]")).to_not be
    end
  end

  describe "getting coverage results" do
    let(:touched) { %w[First Second Third Fourth Fifth] }
    let(:untouched) { %w[Sixth Seventh Eighth Nineth] }

    before do
      touched.each do |title|
        subject.add("Notify[#{title}]")
        subject.cover!("Notify[#{title}]")
      end
      untouched.each do |title|
        subject.add("Notify[#{title}]")
      end
    end

    let(:report) { subject.results }

    it "counts the total number of resources" do
      expect(report[:total]).to eq 9
    end

    it "counts the number of touched resources" do
      expect(report[:touched]).to eq 5
    end

    it "counts the number of untouched resources" do
      expect(report[:untouched]).to eq 4
    end

    it "counts the coverage percentage" do
      expect(report[:coverage]).to eq "55.56"
    end

    it "includes all resources and their status" do
      resources = report[:resources]
      touched.each do |name|
        expect(resources["Notify[#{name}]"]).to eq(:touched => true)
      end
      untouched.each do |name|
        expect(resources["Notify[#{name}]"]).to eq(:touched => false)
      end
    end
  end
end
