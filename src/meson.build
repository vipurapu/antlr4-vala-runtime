deps = []
foreach d : get_option('dependencies')
  deps += dependency(d)
endforeach

message(get_option('sources').length())
pkgc = import('pkgconfig')

lib = shared_library(
  'antlr4vala',
  get_option('sources'),
  vala_vapi : 'antlr-4.8.vapi',
  vala_args : ['--target-glib=2.52'],
  dependencies: deps,
  install : true,
)

executable(
  'log-test',
  'Antlr4.Runtime/Misc/logmanager.vala',
  dependencies : deps,
)

pkgc.generate(
  lib,
  version : '4.8',
  name : 'libantlr4vala',
  filebase : 'antlr-4.8',
  description : 'ANTLR 4.8 runtime for Vala.',
)
