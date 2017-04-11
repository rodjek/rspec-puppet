class test::bare_class {
  notify { 'foo': }
  include dynamic::create_resources
}
