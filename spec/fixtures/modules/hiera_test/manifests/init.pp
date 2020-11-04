class hiera_test (
  $test_param,
) {
  notify { $test_param: }
}