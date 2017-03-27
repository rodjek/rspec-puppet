class test::windows {
  file { 'C:\\test.txt':
    content  => 'something',
    ensure   => file,
    provider => windows,
  }
}
