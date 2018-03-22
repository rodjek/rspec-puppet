class map_reduce (
  Array[Integer] $values
) {
  $incremented_values = $values.map |$x| { $x + 1 }
  $result = $incremented_values.reduce('') |$memo, $x| { "${memo}${x}" }
  notify { 'joined_incremented_values':
    message => $result,
  }
}
