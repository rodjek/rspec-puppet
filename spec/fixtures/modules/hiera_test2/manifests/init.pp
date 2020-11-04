class hiera_test2 (
  $test_param,
) {
  notify { $test_param: }
}
