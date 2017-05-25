class node_params {
  notify { 'string':
    message => $::string,
  }

  if $facts { # protect against puppet 3 not having $facts hash
    notify { 'stringfact':
      message => "${facts['string']}",
    }
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
