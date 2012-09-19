class virtual::realise_file {
  @file { '/foo':
    owner => 'root',
    group => 'root',
  }
  @file { '/bar':
    owner => 'root',
    group => 'root',
  }
  File<| title == '/foo' |>
}
