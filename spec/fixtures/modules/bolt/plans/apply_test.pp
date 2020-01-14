plan bolt::apply_test(
  TargetSpec $nodes,
) {
  apply($nodes) {
    notify { 'foo': }
  }
}
