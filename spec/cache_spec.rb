require 'spec_helper'
require 'rspec-puppet/cache'

describe RSpec::Puppet::Cache do
  let(:compiler) { {} }

  subject do
    described_class.new do |args|
      compiler[args]
    end
  end

  describe "fetching cached entries" do
    it "calls the get_proc on cache misses" do
      compiler["example.com"] = "New catalog!"
      fetched_obj = subject.get("example.com")
      expect(fetched_obj).to eq("New catalog!")
    end

    it "can supply a proc to the get method" do
      compiler["example.com"] = "New catalog!"
      fetched_obj = subject.get("example.com") do |args|
        compiler[args] + "!!"
      end
      expect(fetched_obj).to eq("New catalog!!!")
    end

    it "can handle procs with multiple args" do
      compiler["example.com"] = "New catalog!"
      fetched_obj = subject.get("example.com", " Yay!") do |arg1, arg2|
        compiler[arg1] + arg2
      end
      expect(fetched_obj).to eq("New catalog! Yay!")
    end

    it "reuses cached entries" do
      compiler["example.com"] = "Cachable catalog!"

      first = subject.get("example.com")
      second = subject.get("example.com")

      expect(first.object_id).to eq(second.object_id)
    end

    it "evicts expired entries" do
      compiler["evicting.example.com"] = "Catalog to evict"
      0.upto(15) do |i|
        compiler["node#{i}.example.com"] = "Catalog for node #{i}"
      end

      first = subject.get("evicting.example.com")
      0.upto(15) do |i|
        subject.get("node#{i}.example.com")
      end
      compiler["evicting.example.com"] = "Replacement catalog"
      second = subject.get("evicting.example.com")

      expect(first).to eq("Catalog to evict")
      expect(second).to eq("Replacement catalog")
    end
  end
end
