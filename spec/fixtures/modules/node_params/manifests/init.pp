class node_params {
  notify { 'string':
    message => $::string,
  }

  notify { 'hash':
    message => $::hash,
  }

  notify { 'array':
    message => $::array,
  }

  notify { 'true':
    message => $::true,
  }

  notify { 'false':
    message => $::false,
  }

  notify { 'integer':
    message => $::integer,
  }

  notify { 'float':
    message => $::float,
  }

  notify { 'nil':
    message => $::nil,
  }
}
