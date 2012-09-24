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
def setup_scratch_database(dir)
  require 'puppet/indirector/catalog/active_record'
  Puppet[:storeconfigs] = true
  # trying to be compatible with 2.7 as well as 2.6
  begin
    Puppet[:storeconfigs_backend] = "active_record"
  rescue ArgumentError => e
    # 2.6 has no storeconfigs_backend configuration parameter; it is
    # hard-coded to 'active_record'
  end
  Puppet[:dbadapter]    = 'sqlite3'
  Puppet[:dblocation]   = (dir + "/storeconfigs.sqlite").to_s
  Puppet[:railslog]     = '/dev/null'
  Puppet::Rails.init
end