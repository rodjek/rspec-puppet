# This just makes some nice things available at global scope, and for setup of
# tests to use a real fake database, rather than a fake stubs-that-don't-work
# version of the same.  Fun times.
def sqlite?
  if $sqlite.nil?
    begin
      require 'sqlite3'
      $sqlite = true
    rescue LoadError
      $sqlite = false
    end
  end
  $sqlite
end

def can_use_scratch_database?
  sqlite? and Puppet.features.rails?
end

# This is expected to be called in your `before :each` block, and will get you
# ready to roll with a serious database and all.  Cleanup is handled
# automatically for you.  Nothing to do there.
def setup_scratch_database
  require 'puppet/indirector/catalog/active_record'
  Puppet[:storeconfigs] = true
  Puppet[:environment]  = "production"
  Puppet[:storeconfigs_backend] = "active_record"
  Puppet::Rails.stubs(:database_arguments).returns(
    :adapter => 'sqlite3',
    :log_level => Puppet[:rails_loglevel],
    :database => ':memory:'
  )
  Puppet[:railslog]     = '/dev/null'
  Puppet::Rails.init
end
