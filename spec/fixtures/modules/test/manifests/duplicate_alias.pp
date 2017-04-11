class test::duplicate_alias {
  exec { 'foo_bar_1':
    command => '/bin/echo foo bar',
  }

  exec { 'foo_bar_2':
    command => '/bin/echo foo bar',
  }
}
