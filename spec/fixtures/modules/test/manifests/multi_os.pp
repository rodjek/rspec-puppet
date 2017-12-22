class test::multi_os {
  $file = $::operatingsystem ? {
    'windows' => 'C:/test',
    default   => '/test',
  }

  file { $file:
    ensure => file,
  }
}
