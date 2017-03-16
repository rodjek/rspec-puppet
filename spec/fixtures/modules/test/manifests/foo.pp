class test::foo {
  $my_managehome = $::osfamily ? {
    'Darwin' => 'false',
    default  => true,
  }

  file { '/home': ensure => directory }
  user { 'testuser':
    managehome => $my_managehome,
    home       => '/home/testuser',
  }
}
