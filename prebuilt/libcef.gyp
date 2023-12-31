{
	'includes':
	[
		'../common.gypi',
	],
	
	'targets':
	[
		{
			'target_name': 'libcef',
			'type': 'none',

			'toolsets': ['host', 'target'],
			
			'dependencies':
			[
				'fetch.gyp:fetch',
			],
			
			'direct_dependent_settings':
			{
				'defines':
				[
					'USING_CEF_SHARED=1',
				],
			},
						
			'conditions':
			[   
                [
				    'OS == "win"',
				    {
					    'copies':
					    [
						    {
							    'destination':'<(PRODUCT_DIR)/Externals/CEF/',
							    'files':
							    [
								    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/cef.pak',
								    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/cef_100_percent.pak',
								    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/cef_200_percent.pak',
								    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/cef_extensions.pak',
								    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/d3dcompiler_47.dll',
								    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/devtools_resources.pak',
								    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/icudtl.dat',
								    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/libcef.dll',
								    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/libEGL.dll',
								    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/libGLESv2.dll',
								    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/natives_blob.bin',
								    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/snapshot_blob.bin',
								    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/v8_context_snapshot.bin',
							        'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/chrome_elf.dll',
							    ],
						    },
							{
							    'destination':'<(PRODUCT_DIR)/Externals/CEF/swiftshader',
							    'files':
							    [
								    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/swiftshader/libEGL.dll',
								    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/swiftshader/libGLESv2.dll',
							    ],
						    },
                            {
                                'destination': '<(PRODUCT_DIR)/Externals/CEF/locales',
                                'files':
                                [
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/am.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/ar.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/bg.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/bn.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/ca.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/cs.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/de.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/el.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/en-GB.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/en-US.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/es.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/es-419.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/et.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/fa.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/fi.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/fil.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/fr.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/gu.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/he.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/hi.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/hr.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/hu.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/id.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/it.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/ja.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/kn.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/ko.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/lt.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/lv.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/ml.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/mr.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/ms.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/nb.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/nl.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/pl.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/pt-BR.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/pt-PT.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/ro.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/ru.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/sk.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/sl.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/sr.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/sv.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/sw.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/ta.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/te.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/th.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/tr.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/uk.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/vi.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/zh-CN.pak',
                                    'unpacked/cef/<(uniform_arch)-win32-$(PlatformToolset)_static_$(ConfigurationName)/lib/CEF/locales/zh-TW.pak',
                                ],
                            },
                        ],

					    'all_dependent_settings':
					    {
						    'variables':
						    {
							    # Gyp will only use a recursive xcopy if the path ends with '/'
							    'dist_aux_files': [ '<(PRODUCT_DIR)/Externals/', ],
						    },
					    },
				    },
				],
				
				[
				    'OS == "linux" and target_arch in ("x86", "x86_64")',
                    {
                        'copies':
                        [
                            {
                                'destination': '<(PRODUCT_DIR)/Externals/CEF',
                                'files':
                                [
# these are available at https://cef-builds.spotifycdn.com/index.html#linux64
                                    'lib/linux/<(target_arch)/CEF/cef.pak',
                                    'lib/linux/<(target_arch)/CEF/cef_100_percent.pak',
                                    'lib/linux/<(target_arch)/CEF/cef_200_percent.pak',
                                    'lib/linux/<(target_arch)/CEF/cef_extensions.pak',
                                    'lib/linux/<(target_arch)/CEF/devtools_resources.pak',
                                    'lib/linux/<(target_arch)/CEF/libcef.so',
                                    'lib/linux/<(target_arch)/CEF/libEGL.so',
                                    'lib/linux/<(target_arch)/CEF/libGLESv2.so',
                                    'lib/linux/<(target_arch)/CEF/chrome-sandbox',
									'lib/linux/<(target_arch)/CEF/natives_blob.bin',
                                    'lib/linux/<(target_arch)/CEF/snapshot_blob.bin',
                                    'lib/linux/<(target_arch)/CEF/v8_context_snapshot.bin',
                                    'lib/linux/<(target_arch)/CEF/icudtl.dat',
                                ],
                            },
#							{
#                                'destination': '<(PRODUCT_DIR)/Externals/CEF/swiftshader',
#                                'files':
#                                [
#                                    'lib/linux/<(target_arch)/CEF/swiftshader/libEGL.so',
#                                    'lib/linux/<(target_arch)/CEF/swiftshader/libGLESv2.so',
#                                ],
#                            },
                            {
                                'destination': '<(PRODUCT_DIR)/Externals/CEF/locales',
                                'files':
                                [
                                    'lib/linux/<(target_arch)/CEF/locales/am.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/ar.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/bg.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/bn.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/ca.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/cs.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/de.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/el.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/en-GB.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/en-US.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/es.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/es-419.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/et.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/fa.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/fi.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/fil.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/fr.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/gu.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/he.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/hi.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/hr.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/hu.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/id.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/it.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/ja.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/kn.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/ko.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/lt.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/lv.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/ml.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/mr.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/ms.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/nb.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/nl.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/pl.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/pt-BR.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/pt-PT.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/ro.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/ru.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/sk.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/sl.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/sr.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/sv.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/sw.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/ta.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/te.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/th.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/tr.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/uk.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/vi.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/zh-CN.pak',
                                    'lib/linux/<(target_arch)/CEF/locales/zh-TW.pak',
                                ],
                            },
                        ],
                        
					    'all_dependent_settings':
					    {
						    'variables':
						    {
							    'dist_aux_files':
                                [
                                    '<(PRODUCT_DIR)/Externals/',
                                ],
						    },
					    },
				    },
				],
			],
		},
	],
}
