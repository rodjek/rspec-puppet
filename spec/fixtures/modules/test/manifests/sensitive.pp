class test::sensitive::user (
  Sensitive[String] $password,
) {}

class test::sensitive {
  $data = Sensitive('myPassword')
  class { 'test::sensitive::user':
    password => $data,
  }
}
