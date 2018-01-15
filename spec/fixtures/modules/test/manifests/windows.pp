class test::windows {
  file { 'C:\\test.txt':
    content  => 'something',
    ensure   => file,
    mode     => '0755',
    provider => windows,
  }

  file { 'C:\\something.txt':
    ensure => link,
    target => 'C:\\test.txt',
  }

  package { 'test':
    ensure => 'installed',
  }
}
