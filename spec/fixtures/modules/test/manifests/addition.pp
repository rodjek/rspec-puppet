define test::addition($value) {
  $result = $value + 1

  # force conversion to string
  notify { "${result}": }
}

