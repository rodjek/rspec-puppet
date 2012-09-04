class exported::realise_file {
  File <<| owner == 'root' |>>
  File <<| group != 'daemon' |>>
}
