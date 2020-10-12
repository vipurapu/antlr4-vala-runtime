project('antlr4-vala-runtime', ['c', 'vala'],
          version: '0.1.0',
    meson_version: '>= 0.50.0',
  default_options: [ 'warning_level=2',
                   ],
)

subdir('src')

command = [
  	'valadoc',
  	'--directory=' + meson.source_root() / 'doc',
  	'--pkg=gee-0.8',
  	'--internal',
  	'--private',
  	'--package-name=antlr-4.8',
]

foreach s : get_option('sources')
	command += meson.source_root() / 'src' / s
endforeach

custom_target (
  'doc',
  command : command,
  input : 'src/Antlr4.Runtime',
  output : 'doc',
)
