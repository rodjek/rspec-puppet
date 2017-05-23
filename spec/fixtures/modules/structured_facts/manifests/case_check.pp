class structured_facts::case_check {
  $_value = $facts['custom_fact']['MixedCase']
  notify { "$_value": }
}
