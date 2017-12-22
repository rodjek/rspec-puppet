class test::windows {
  file { 'C:\\test.txt':
    content  => 'something',
    ensure   => file,
    mode     => '0755',
    provider => windows,
  }
}
