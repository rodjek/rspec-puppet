class test::hiera {
  $message = hiera('data', 'not found')
  notify { $message: }
}
