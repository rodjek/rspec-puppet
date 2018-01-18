class type_mismatch {
  $hash = {
    'foo' => {
      'bar' => [],
    },
  }

  type_mismatch::hash { 'bug':
    hash => $hash,
  }
}
