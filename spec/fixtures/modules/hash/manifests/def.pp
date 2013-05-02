define hash::def($data = {}) {
  $template = inline_template('<%= data.flatten.join(",") %>')

  notify { "$template": }
}
