class test::user {
  user { 'luke':
    ensure => present,
    uid    => '501',
  }
}
