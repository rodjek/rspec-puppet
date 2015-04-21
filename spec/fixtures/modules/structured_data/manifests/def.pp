define structured_data::def($data = {}) {
  $template = inline_template('<%= @data.inspect %>')

  notify { "$template": }
}
