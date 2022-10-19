node default {
  notify { 'test': }
}

node 'testhost_a' {
  file { '/tmp/a': }
}

node /testhost/ {
  include sysctl::common
}

node 'good_dep_host' {
  file { 'tmpdir':
    alias => '/tmp',
    path  => '/tmp',
  }
  file { '/tmp/deptest1':
    require => File['tmpdir'],
  }
  file { '/tmp/deptest2':
    require => File['/tmp'],
  }
}

node 'facts.acme.com' {
  file { 'environment':
    path => $environment
  }
  if $::environment == 'test_env' {
    file { 'conditional_file':
      path => 'ignored'
    }
  }
  file { 'clientversion':
    path => $clientversion
  }
  file { 'fqdn':
    path => $fqdn
  }
  file { 'hostname':
    path => $hostname
  }
  file { 'domain':
    path => $domain
  }
  file { 'clientcert':
    path => "cert ${clientcert}"
  }
}

node 'tags_testing' {
  tag 'keyword_tag'
  include sysctl::common
  file { '/tmp/a':
    ensure => present
  }
  file { '/tmp/b':
    ensure => present,
    tag    => 'metaparam_tag'
  }
}
