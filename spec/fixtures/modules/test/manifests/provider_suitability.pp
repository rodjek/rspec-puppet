class test::provider_suitability {
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
