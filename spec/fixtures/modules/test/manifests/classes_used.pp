class test::classes_used {
  include test::bare_class

  class { 'test::parameterised_class':
    text => 'bar',
  }
}
