class boolean($bool) {
  $real_bool = $bool ? {
    true => false,
    false => true,
  }
  
  if ($real_bool) {
    notify {"bool testing":
      message => "This will print when \$bool is false."
    }
  }
}
