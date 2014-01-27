class test::compile_error {
  user { 'foo':
    ensure     => present,
    managehome => true,
    provider   => 'directoryservice',
  }
}
