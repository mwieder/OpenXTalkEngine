{
	'variables':
	{
		# Sources shared between desktop and server builds
		'engine_common_source_files':
		[	
			# Group "Core - Graphics"
			'include/customprinter.h',
			'src/bitmapeffect.h',
			'src/bitmapeffectblur.h',
			'src/color.h',
			'src/context.h',
			'src/font.h',
			'src/gradient.h',
			'src/graphics_util.h',
			'src/graphicscontext.h',
			'src/imagelist.h',
			'src/mctheme.h',
			'src/metacontext.h',
			'src/packed.h',
			'src/paint.h',
			'src/path.h',
			'src/pathprivate.h',
			'src/redraw.h',
			'src/region.h',
			'src/resolution.h',
			'src/textlayout.h',
			'src/tilecache.h',
			'src/bitmapeffect.cpp',
			'src/bitmapeffectblur.cpp',
			'src/color.cpp',
			'src/combiners.cpp',
			'src/customprinter.cpp',
			'src/font.cpp',
			'src/fonttable.cpp',
			'src/gradient.cpp',
			'src/graphics_util.cpp',
			'src/graphicscontext.cpp',
			'src/imagelist.cpp',
			'src/mctheme.cpp',
			'src/metacontext.cpp',
			'src/path.cpp',
			'src/pathgray.cpp',
			'src/pathprocess.cpp',
			'src/printer.cpp',
			'src/redraw.cpp',
			'src/region.cpp',
			'src/resolution.cpp',
			'src/rgb.cpp',
			'src/surface.cpp',
			'src/tilecache.cpp',
			'src/tilecachecg.cpp',
			'src/tilecachegl.cpp',
			'src/tilecachesw.cpp',
			
			# Group "Core - Language"
			'src/ans.h',
			'src/answer.h',
			'src/ask.h',
			'src/chunk.h',
			'src/cmds.h',
			'src/constant.h',
			'src/date.h',
			'src/executionerrors.h',
			'src/express.h',
			'src/external.h',
			'src/externalv1.h',
			'src/funcs.h',
			'src/handler.h',
			'src/hndlrlst.h',
			'src/internal.h',
			'src/keywords.h',
			'src/literal.h',
			'src/newobj.h',
			'src/operator.h',
			'src/param.h',
			'src/parseerrors.h',
			'src/property.h',
			'src/scriptpt.h',
			'src/statemnt.h',
			'src/variable.h',
			'src/variable_impl.h',
			'src/visual.h',
			'src/answer.cpp',
			'src/ask.cpp',
			'src/chunk.cpp',
			'src/cmds.cpp',
			'src/cmdsc.cpp',
			'src/cmdse.cpp',
			'src/cmdsf.cpp',
			'src/cmdsm.cpp',
			'src/cmdsp.cpp',
			'src/cmdss.cpp',
			'src/constant.cpp',
			'src/date.cpp',
			'src/express.cpp',
			'src/external.cpp',
			'src/externalv0.cpp',
			'src/externalv1.cpp',
			'src/externalv1.mm',
			'src/funcs.cpp',
			'src/funcsm.cpp',
			'src/handler.cpp',
			'src/hndlrlst.cpp',
			'src/keywords.cpp',
			'src/literal.cpp',
			'src/keywords.cpp',
			'src/newobj.cpp',
			'src/operator.cpp',
			'src/param.cpp',
			'src/property.cpp',
			'src/scriptpt.cpp',
			'src/statemnt.cpp',
			'src/variable.cpp',
			'src/visual.cpp',
			
			# Group "Core - Misc"
			'<(SHARED_INTERMEDIATE_DIR)/include/revbuild.h',
			'src/capsule.h',
			'src/datastructures.h',
			'src/debug.h',
			'src/dllst.h',
			'src/eventqueue.h',
			'src/fiber.h',
			'src/filedefs.h',
			'src/filepath.h',
			'src/flst.h',
			'src/globals.h',
			'src/license.h',
			'src/mcerror.h',
			'src/mcio.h',
			'src/mcssl.h',
			'src/mcstring.h',
			'src/mcutility.h',
			'src/md5.h',
			'src/meta.h',
			'src/mode.h',
			'src/notify.h',
			'src/osspec.h',
			'src/parsedef.h',
			'src/prefix.h',
			'src/regex.h',
			'src/resource.h',
			'src/scriptenvironment.h',
			'src/securemode.h',
			'src/sha1.h',
			'src/text.h',
			'src/transfer.h',
			'src/uidc.h',
			'src/unicode.h',
			'src/util.h',
			'src/uuid.h',
			'src/capsule.cpp',
			'src/debug.cpp',
			'src/dllst.cpp',
			'src/eventqueue.cpp',
			'src/fiber.cpp',
			'src/filepath.cpp',
			'src/globals.cpp',
			'src/mcerror.cpp',
			'src/mcio.cpp',
			'src/mcssl.cpp',
			'src/mcstring.cpp',
			'src/mcutility.cpp',
			'src/md5.cpp',
			'src/notify.cpp',
			'src/opensslsocket.cpp',
			'src/ports.cpp',
			'src/regex.cpp',
			'src/securemode.cpp',
			'src/sha1.cpp',			
			'src/text.cpp',
			'src/transfer.cpp',
			'src/uidc.cpp',
			'src/unicode.cpp',
			'src/util.cpp',
			'src/uuid.cpp',
			
			# Group "Core - Objects"
			'src/aclip.h',
			'src/MCBlock.h',
			'src/button.h',
			'src/card.h',
			'src/cardlst.h',
			'src/cdata.h',
			'src/control.h',
			'src/cpalette.h',
			'src/dispatch.h',
			'src/edittool.h',
			'src/eps.h',
			'src/field.h',
			'src/graphic.h',
			'src/group.h',
			'src/hc.h',
			'src/image.h',
			'src/image_rep.h',
			'src/imagebitmap.h',
			'src/imageloader.h',
			'src/iquantization.h',
			'src/line.h',
			'src/magnify.h',
			'src/menuparse.h',
			'src/objdefs.h',
			'src/object.h',
			'src/objectstream.h',
			'src/objptr.h',
			'src/paragraf.h',
			'src/parentscript.h',
			'src/player.h',
			'src/player-platform.h',
			'src/rtf.h',
			'src/scrolbar.h',
			'src/sellst.h',
			'src/stack.h',
			'src/stacklst.h',
			'src/styledtext.h',
			'src/textbuffer.h',
			'src/tooltip.h',
			'src/undolst.h',
			'src/vclip.h',
			'src/widget.h',
			'src/widget-events.h',
			'src/aclip.cpp',
			'src/block.cpp',
			'src/button.cpp',
			'src/buttondraw.cpp',
			'src/card.cpp',
			'src/cardlst.cpp',
			'src/cdata.cpp',
			'src/control.cpp',
			'src/cpalette.cpp',
			'src/dispatch.cpp',
			'src/edittool.cpp',
			'src/eps.cpp',
			'src/field.cpp',
			'src/fieldf.cpp',
			'src/fieldh.cpp',
			'src/fieldhtml.cpp',
			'src/fieldrtf.cpp',
			'src/fields.cpp',
			'src/fieldstyledtext.cpp',
			'src/graphic.cpp',
			'src/group.cpp',
			'src/hc.cpp',
			'src/ibmp.cpp',
			'src/icondata.cpp',
			'src/idraw.cpp',
			'src/ifile.cpp',
			'src/igif.cpp',
			'src/iimport.cpp',
			'src/ijpg.cpp',
			'src/image.cpp',
			'src/image_rep.cpp',
			'src/image_rep_densitymapped.cpp',
			'src/image_rep_encoded.cpp',
			'src/image_rep_mutable.cpp',
			'src/image_rep_resampled.cpp',
			'src/imagebitmap.cpp',
			'src/imageloader.cpp',
			'src/ipng.cpp',
			'src/iquantization.cpp',
			'src/iquantize_new.cpp',
			'src/irle.cpp',
			'src/itransform.cpp',
			'src/iutil.cpp',
			'src/line.cpp',
			'src/magnify.cpp',
			'src/menuparse.cpp',
			'src/object.cpp',
			'src/objectprops.cpp',
			'src/objectpropsets.cpp',
			'src/objectstream.cpp',
			'src/objptr.cpp',
			'src/paragraf.cpp',
			'src/paragrafattr.cpp',
			'src/parentscript.cpp',
			'src/pickle.cpp',
			'src/player-platform.cpp',
			'src/player.cpp',
			'src/props.cpp',
			'src/rtf.cpp',
			'src/rtfsupport.cpp',
			'src/scrolbar.cpp',
			'src/scrollbardraw.cpp',
			'src/segment.cpp',
			'src/sellst.cpp',
			'src/stack.cpp',
			'src/stack2.cpp',
			'src/stack3.cpp',
			'src/stackcache.cpp',
			'src/stacke.cpp',
			'src/stacklst.cpp',
			'src/stackview.cpp',
			'src/styledtext.cpp',
			'src/tooltip.cpp',
			'src/undolst.cpp',
			'src/vclip.cpp',
			'src/widget.cpp',
			'src/widget-events.cpp',
			
			# Group "Desktop"
			'src/dskmac.cpp',
			'src/dsklnx.cpp',
			'src/dskw32.cpp',
			
			# Group "Exec"
			'src/exec.h',
			'src/exec-interface.h',
			'src/exec-strings.h',
			'src/exec.cpp',
			'src/exec-ad.cpp',
			'src/exec-array.cpp',
			'src/exec-addressbook.cpp',
			'src/exec-busyindicator.cpp',
			'src/exec-calendar.cpp',
			'src/exec-datetime.cpp',
			'src/exec-debugging.cpp',
			'src/exec-dialog.cpp',
			'src/exec-engine.cpp',
			'src/exec-extension.cpp',
			'src/exec-files.cpp',
			'src/exec-filters.cpp',
			'src/exec-graphics.cpp',
			'src/exec-ide.cpp',
			'src/exec-idletimer.cpp',
			'src/exec-interface.cpp',
			'src/exec-interface2.cpp',
			'src/exec-interface-aclip.cpp',
			'src/exec-interface-button.cpp',
			'src/exec-interface-card.cpp',
			'src/exec-interface-control.cpp',
			'src/exec-interface-field.cpp',
			'src/exec-interface-field-chunk.cpp',
			'src/exec-interface-graphic.cpp',
			'src/exec-interface-group.cpp',
			'src/exec-interface-image.cpp',
			'src/exec-interface-object.cpp',
			'src/exec-interface-player.cpp',
			'src/exec-interface-scrollbar.cpp',
			'src/exec-interface-stack.cpp',
			'src/exec-interface-vclip.cpp',
			'src/exec-keywords.cpp',
			'src/exec-legacy.cpp',
			'src/exec-logic.cpp',
			'src/exec-mail.cpp',
			'src/exec-math.cpp',
			'src/exec-misc.cpp',
			'src/exec-multimedia.cpp',
			'src/exec-nativecontrol.cpp',
			'src/exec-network.cpp',
			'src/exec-notification.cpp',
			'src/exec-orientation.cpp',
			'src/exec-pasteboard.cpp',
			'src/exec-pick.cpp',
			'src/exec-printing.cpp',
			'src/exec-scripting.cpp',
			'src/exec-security.cpp',
			'src/exec-sensor.cpp',
			'src/exec-server.cpp',
			'src/exec-sound.cpp',
			'src/exec-store.cpp',
			'src/exec-strings.cpp',
			'src/exec-strings-chunk.cpp',
			'src/exec-text.cpp',
			'src/exec-textmessaging.cpp',
			
			# Group "Foundation"
			'src/foundation-legacy.h',
			'src/foundation-legacy.cpp',
			
			# Group "Mobile"
			'src/mblad.h',
			'src/mblcalendar.h',
			'src/mblcontact.h',
			'src/mblcontrol.h',
			'src/mbldc.h',
			'src/mblevent.h',
			'src/mblflst.h',
			'src/mblnotification.h',
			'src/mblsensor.h',
			'src/mblstore.h',
			'src/mblsyntax.h',
			'src/mblad.cpp',
			'src/mblcalendar.cpp',
			'src/mblcamera.cpp',
			'src/mblcontact.cpp',
			'src/mblcontrol.cpp',
			'src/mbldc.cpp',
			'src/mbldialog.cpp',
			'src/mblflst.cpp',
			'src/mblhandlers.cpp',
			'src/mblmain.cpp',
			'src/mblnotification.cpp',
			'src/mblsensor.cpp',
			'src/mblspec.cpp',
			'src/mblstack.cpp',
			'src/mblstore.cpp',
			'src/mblsound.cpp',
			'src/mbltheme.cpp',
			
			# Group "Mobile - Android"
			'src/mblandroid.h',
			'src/mblandroidcontrol.h',
			'src/mblandroidjava.h',
			'src/mblandroidtypeface.h',
			'src/mblandroidutil.h',
			'src/mblandroid.cpp',
			'src/mblandroidbrowser.cpp',
			'src/mblandroidbusyindicator.cpp',
			'src/mblandroidcalendar.cpp',
			'src/mblandroidcamera.cpp',
			'src/mblandroidcontact.cpp',
			'src/mblandroidcontrol.cpp',
			'src/mblandroiddc.cpp',
			'src/mblandroiddialog.cpp',
			'src/mblandroidfont.cpp',
			'src/mblandroidfs.cpp',
			'src/mblandroididletimer.cpp',
			'src/mblandroidinput.cpp',
			'src/mblandroidio.cpp',
			'src/mblandroidjava.cpp',
			'src/mblandroidmail.cpp',
			'src/mblandroidmediapick.cpp',
			'src/mblandroidmisc.cpp',
			'src/mblandroidmm.cpp',
			'src/mblandroidnetwork.cpp',
			'src/mblandroidnotification.cpp',
			'src/mblandroidorientation.cpp',
			'src/mblandroidplayer.cpp',
			'src/mblandroidprocess.cpp',
			'src/mblandroidscroller.cpp',
			'src/mblandroidsensor.cpp',
			'src/mblandroidstore.cpp',
			'src/mblandroidsound.cpp',
			'src/mblandroidtextlayout.cpp',
			'src/mblandroidtextmessaging.cpp',
			'src/mblandroidtypeface.cpp',
			'src/mblandroidurl.cpp',
			
			# Group "Mobile - iOS"
			'src/mbliphone.h',
			'src/mbliphoneapp.h',
			'src/mbliphonecontrol.h',
			'src/mbliphoneview.h',
			'src/mbliphone.mm',
			'src/mbliphonead.mm',
			'src/mbliphoneactivityindicator.mm',
			'src/mbliphoneapp.mm',
			'src/mbliphoneappview.mm',
			'src/mbliphonebrowser.mm',
			'src/mbliphonebusyindicator.mm',
			'src/mbliphonecalendar.mm',
			'src/mbliphonecamera.mm',
			'src/mbliphonecontact.mm',
			'src/mbliphonecontrol.mm',
			'src/mbliphonedc.mm',
			'src/mbliphonedialog.mm',
			#'src/mbliphoneembedded.mm',
			#'src/mbliphoneembeddedtest.mm',
			'src/mbliphoneextra.mm',
			'src/mbliphonefs.mm',
			'src/mbliphonegfx.mm',
			'src/mbliphonehooks.cpp',
			'src/mbliphoneidletimer.mm',
			'src/mbliphoneinput.mm',
			'src/mbliphonemail.mm',
			'src/mbliphonemediapick.mm',
			'src/mbliphonemisc.mm',
			'src/mbliphonenotification.mm',
			'src/mbliphoneorientation.mm',
			'src/mbliphonepick.mm',
			'src/mbliphonepickdate.mm',
			'src/mbliphoneplayer.mm',
			'src/mbliphonereachability.mm',
			'src/mbliphonescroller.mm',
			'src/mbliphonesensor.mm',
			'src/mbliphonesound.mm',
			'src/mbliphonestack.mm',
			'src/mbliphonestore.mm',
			#'src/mbliphonetextlayout.mm',
			'src/mbliphonetextmessaging.mm',
			'src/mbliphoneurl.mm',
			'src/mbliphonevideo.mm',
			
			# Group "System"
			'src/globdefs.h',
			'src/osspec.h',
			'src/sysdefs.h',
			'src/system.h',
			'src/typedefs.h',
			'src/syscfdate.cpp',
			'src/syslnxfs.cpp',
			'src/syslnxregion.cpp',
			'src/sysosxregion.cpp',
			'src/sysspec.cpp',
			'src/sysunxdate.cpp',
			'src/sysunxnetwork.cpp',
			'src/sysw32fs.cpp',
			'src/sysw32network.cpp',
			'src/sysw32region.cpp',
			'src/sysw32registry.cpp',
			
			# Group "Text"
			'src/text.h',
			'src/text-api.h',
			'src/text-block.h',
			'src/text-breakblock.h',
			'src/text-breakingengine.h',
			'src/text-cell.h',
			'src/text-controlblock.h',
			'src/text-imageblock.h',
			'src/text-line.h',
			'src/text-pane.h',
			'src/text-paragraph.h',
			'src/text-run.h',
			'src/text-segment.h',
			'src/text-simplebreakingengine.h',
			'src/text.cpp',
			'src/text-api.cpp',
			'src/text-block.cpp',
			'src/text-breakblock.cpp',
			'src/text-breakingengine.cpp',
			'src/text-cell.cpp',
			'src/text-controlblock.cpp',
			'src/text-imageblock.cpp',
			'src/text-line.cpp',
			'src/text-pane.cpp',
			'src/text-paragraph.cpp',
			'src/text-run.cpp',
			'src/text-segment.cpp',
			'src/text-simplebreakingengine.cpp',
			
			# Group "Desktop"
			'src/quicktime.cpp',
			'src/quicktime.stubs',
			'<(SHARED_INTERMEDIATE_DIR)/src/quicktimestubs.mac.cpp',
			
			# Group "Desktop - Mac"
			'src/coretextfonts.cpp',
			'src/osxflst.cpp',
			
			# Group "Desktop - Linux"
			'src/lnxelevate.cpp',
			'src/lnxflst.cpp',
			
			# Group "Desktop - Windows"
			'src/w32date.cpp',
							
			# Group "Theming"
			'src/linux-theme.cpp',
			'src/mac-theme.mm',
			'src/windows-theme.cpp',
				
			# Group "Syntax"
			'src/syntax.h',
			'src/syntax.cpp',
			
			# Other files
			'src/socket_resolve.cpp',
		],
		
		# Sources that are only for desktop mode
		'engine_desktop_source_files':
		[
			# Group "Desktop"
			'src/desktop-dc.h',
			'src/dsklnxmain.cpp',
			'src/dskmain.cpp',
			'src/dskw32main.cpp',
			'src/dskspec.cpp',
			'src/desktop.cpp',
			'src/desktop-dc.cpp',
			'src/desktop-stack.cpp',
			'src/desktop-menu.cpp',
			'src/desktop-pasteboard.cpp',
			'src/desktop-image.cpp',
			'src/desktop-ans.cpp',
			'src/legacy_spec.cpp',
			
			# Group "Platform"
			'src/platform.h',
			'src/platform.cpp',
			'src/platform-internal.h',
			'src/platform-recorder.cpp',
			'src/platform-surface.cpp',
			'src/platform-window.cpp',
			
			# Group "Desktop - Linux"
			'src/lnxans.h',
			'src/lnxaudio.h',
			'src/lnxdc.h',
			'src/lnxdnd.h',
			'src/lnxflst.h',
			'src/lnxgtkthemedrawing.h',
			'src/lnximagecache.h',
			'src/lnxmplayer.h',
			'src/lnxpasteboard.h',
			'src/lnxprefix.h',
			'src/lnxpsprinter.h',
			'src/lnxtheme.h',
			'src/lnxtransfer.h',
			'src/lnxans.cpp',
			'src/lnxaudio.cpp',
			'src/lnxclipboard.cpp',
			'src/lnxcolor.cpp',
			'src/lnxcursor.cpp',
			'src/lnxdc.cpp',
			'src/lnxdce.cpp',
			'src/lnxdclnx.cpp',
			'src/lnxdcs.cpp',
			'src/lnxdnd.cpp',
			'src/lnxflstold.cpp',
			'src/lnxgtktheme.cpp',
			'src/lnxgtkthemedrawing.cpp',
			'src/lnximage.cpp',
			'src/lnximagecache.cpp',
			'src/lnxkeymapping.cpp',
			'src/lnxmisc.cpp',
			'src/lnxmplayer.cpp',
			'src/lnxpasteboard.cpp',
			'src/lnxpsprinter.cpp',
			'src/lnxspec.cpp',
			'src/lnxstack.cpp',
			'src/lnxtextlayout.cpp',
			'src/lnxtransfer.cpp',
			
			# Group "Desktop - Mac"
			'src/mac-internal.h',
			'src/mac-player.h',
			'src/osxflst.h',
			'src/osxprefix.h',
			'src/osxprinter.h',
			'src/osxtheme.h',
			'src/cgimageutil.cpp',
			'src/coretextlayout.mm',
			'src/mac-abort.mm',
			'src/mac-av-player.mm',
			'src/mac-color.mm',
			'src/mac-core.mm',
			'src/mac-cursor.mm',
			'src/mac-dialog.mm',
			'src/mac-font.mm',
			'src/mac-menu.mm',
			'src/mac-pasteboard.mm',
			'src/mac-player.mm',
			'src/mac-printer.mm',
			'src/mac-qt-player.mm',
			'src/mac-qt-recorder.mm',
			'src/mac-scripting.mm',
			'src/mac-snapshot.mm',
			'src/mac-sound.mm',
			'src/mac-surface.mm',
			'src/mac-window.mm',
			'src/osxcisupport.mm',
			'src/osxcoreimage.cpp',
			'src/osxfield.cpp',
			'src/osxfiles.cpp',
			'src/osximage.cpp',
			'src/osxmisc.cpp',
			'src/osxprinter.cpp',
			'src/osxstack.cpp',
			'src/osxtextlayout.cpp',
			'src/osxtheme.cpp',
			
			# Group "Desktop - Windows"
			'src/w32compat.h',
			'src/w32dc.h',
			'src/w32defs.h',
			'src/w32dnd.h',
			'src/w32flst.h',
			'src/w32prefix.h',
			'src/w32printer.h',
			'src/w32text.h',
			'src/w32theme.h',
			'src/w32transfer.h',
			'src/w32ans.cpp',
			'src/w32clipboard.cpp',
			'src/w32color.cpp',
			'src/w32compat.cpp',
			'src/w32cursor.cpp',
			'src/w32dc.cpp',
			'src/w32dce.cpp',
			'src/w32dcs.cpp',
			'src/w32dcw32.cpp',
			'src/w32dnd.cpp',
			'src/w32flst.cpp',
			'src/w32icon.cpp',
			'src/w32image.cpp',
			'src/w32misc.cpp',
			'src/w32prefix.cpp',
			'src/w32printer.cpp',
			'src/w32relaunch.cpp',
			'src/w32script.cpp',
			'src/w32sound.cpp',
			'src/w32stack.cpp',
			'src/w32text.cpp',
			'src/w32textlayout.cpp',
			'src/w32theme.cpp',
			'src/w32transfer.cpp',

			# Group "Desktop - Emscripten"
			'src/em-async.h',
			'src/em-async.js',
			'src/em-dc-mainloop.h',
			'src/em-dc-mainloop.cpp',
			'src/em-dc.h',
			'src/em-dc.cpp',
			'src/em-event.h',
			'src/em-event.cpp',
			'src/em-event.js',
			'src/em-filehandle.h',
			'src/em-filehandle.cpp',
			'src/em-fontlist.h',
			'src/em-fontlist.cpp',
			'src/em-main.cpp',
			'src/em-osspec-misc.cpp',
			'src/em-osspec-network.cpp',
			'src/em-resolution.cpp',
			'src/em-stack.cpp',
			'src/em-surface.h',
			'src/em-surface.cpp',
			'src/em-system.h',
			'src/em-system.cpp',
			'src/em-theme.cpp',
			'src/em-util.h',
			'src/em-view.h',
			'src/em-view.cpp',
		],
		
		# Sources that need to be compiled separately for each mode
		'engine_mode_dependent_files':
		[
			'src/lextable.cpp',
			'<(INTERMEDIATE_DIR)/src/encodederrors.cpp',
			#'<(INTERMEDIATE_DIR)/src/hashedstrings.cpp',
		],
		
		# Sources for the Community security module
		'engine_security_source_files':
		[
			'src/stacksecurity.h',
			'src/stacksecurity.cpp',
		],
		
		# Sources for the IDE engine
		'engine_development_mode_source_files':
		[
			# Group "Mode - IDE"
			'src/bsdiff.h',
			'src/deploy.h',
			'src/deploysecurity.h',
			'src/ide.h',
			'src/bsdiff_build.cpp',
			'src/deploy.cpp',
			'src/deploy_capsule.cpp',
			'src/deploy_dmg.cpp',
			'src/deploy_file.cpp',
			'src/deploy_linux.cpp',
			'src/deploy_macosx.cpp',
			'src/deploy_sign.cpp',
			'src/deploy_windows.cpp',
			'src/deploysecurity.cpp',
			'src/ide.cpp',
			'src/internal.cpp',
			'src/internal_development.cpp',
			'src/mode_development.cpp',
		],
		
		# Sources for the installer engine
		'engine_installer_mode_source_files':
		[
			'src/minizip.h',
			'src/bsdiff_apply.cpp',
			'src/internal.cpp',
			'src/minizip.cpp',
			'src/mode_installer.cpp',
			'src/mode_installer_lnx.cpp',
			'src/mode_installer_osx.cpp',
			'src/mode_installer_w32.cpp',
		],
		
		# Sources for the standalone engine
		'engine_standalone_mode_source_files':
		[
			'src/mode_standalone.cpp',
		],
		
		# Sources for the server builds only
		'engine_server_source_files':
		[
			'src/srvcgi.h',
			'src/srvdebug.h',
			'src/srvflst.h',
			'src/srvmain.h',
			'src/srvmultipart.h',
			'src/srvscript.h',
			'src/srvsession.h',
			'src/mode_server.cpp',
			'src/srvcgi.cpp',
			'src/srvdebug.cpp',
			'src/srvflst.cpp',
			'src/srvmain.cpp',
			'src/srvmultipart.cpp',
			'src/srvoutput.cpp',
			'src/srvposix.cpp',
			'src/srvscript.cpp',
			'src/srvsession.cpp',
			'src/srvwindows.cpp',
			'src/srvtheme.cpp',
			'src/srvspec.cpp',
			'src/srvstack.cpp',
		],
		
		# Java sources for Android
		'engine_java_source_files':
		[
			'src/java/com/runrev/android/AccelerationChangeListener.java',
			'src/java/com/runrev/android/Alert.java',
			'src/java/com/runrev/android/AttachmentProvider.java',
			'src/java/com/runrev/android/BitmapView.java',
			'src/java/com/runrev/android/BusyIndicator.java',
			'src/java/com/runrev/android/CalendarEvents.java',
			'src/java/com/runrev/android/CameraCompat.java',
			'src/java/com/runrev/android/Contact.java',
			'src/java/com/runrev/android/DialogModule.java',
			'src/java/com/runrev/android/Email.java',
			'src/java/com/runrev/android/Engine.java',
			'src/java/com/runrev/android/EngineApi.java',
			'src/java/com/runrev/android/EngineReceiver.java',
			'src/java/com/runrev/android/LiveCodeActivity.java',
			'src/java/com/runrev/android/NetworkModule.java',
			'src/java/com/runrev/android/NotificationModule.java',
			'src/java/com/runrev/android/OpenGLView.java',
			'src/java/com/runrev/android/PushReceiver.java',
			'src/java/com/runrev/android/ScreenOrientationEventListener.java',
			'src/java/com/runrev/android/SensorModule.java',
			'src/java/com/runrev/android/ShakeEventListener.java',
			'src/java/com/runrev/android/SoundModule.java',
			'src/java/com/runrev/android/TextMessaging.java',
			'src/java/com/runrev/android/URLLoader.java',
			'src/java/com/runrev/android/Utils.java',
			'src/java/com/runrev/android/billing/BillingProvider.java',
			'src/java/com/runrev/android/billing/BillingModule.java',
			'src/java/com/runrev/android/billing/PurchaseObserver.java',
			#'src/java/com/runrev/android/billing/ResponseHandler.java',
			'src/java/com/runrev/android/billing/google/Base64.java',
			'src/java/com/runrev/android/billing/google/Base64DecoderException.java',
			'src/java/com/runrev/android/billing/google/IabException.java',
			'src/java/com/runrev/android/billing/google/IabHelper.java',
			'src/java/com/runrev/android/billing/google/IabResult.java',
			'src/java/com/runrev/android/billing/google/Inventory.java',
			'src/java/com/runrev/android/billing/google/Purchase.java',
			'src/java/com/runrev/android/billing/google/SkuDetails.java',
			'src/java/com/runrev/android/billing/google/Security.java',
			'src/java/com/runrev/android/billing/google/GoogleBillingProvider.java',
			'src/java/com/runrev/android/billing/samsung/SamsungBillingProvider.java',
			'src/java/com/runrev/android/nativecontrol/BrowserControl.java',
			'src/java/com/runrev/android/nativecontrol/ExtVideoView.java',
			'src/java/com/runrev/android/nativecontrol/InputControl.java',
			'src/java/com/runrev/android/nativecontrol/InputView.java',
			'src/java/com/runrev/android/nativecontrol/NativeControl.java',
			'src/java/com/runrev/android/nativecontrol/NativeControlModule.java',
			'src/java/com/runrev/android/nativecontrol/ScrollerControl.java',
			'src/java/com/runrev/android/nativecontrol/VideoControl.java',
		],
		
		# AIDL sources for Android
		'engine_aidl_source_files':
		[
			'src/java/com/android/vending/billing/IInAppBillingService.aidl',
			'src/java/com/android/vending/billing/IMarketBillingService.aidl',
			'src/java/com/sec/android/iap/IAPServiceCallback.aidl',
			'src/java/com/sec/android/iap/IAPConnector.aidl',
		],
		
		# Sources only used in Commercial Android builds
		'engine_commercial_java_files':
		[
			'src/java/com/runrev/android/AdModule.java',
			'src/java/com/runrev/android/billing/amazon/AmazonBillingProvider.java',
			'src/java/com/runrev/android/billing/amazon/MyPurchasingObserver.java',
		],
		
		
		# Files to be excluded from server builds
		'engine_server_exclude_files':
		[
			'src/player-platform.cpp',
			'src/stacke.cpp',
		],
		
		# Sources used to implement LCB modules in the engine
		'engine_module_source_files':
		[
			'src/module-canvas.h',
			'src/module-canvas-internal.h',
			'src/module-engine.h',
			'src/module-resources.h',
			
			'src/module-canvas.cpp',
			'src/module-engine.cpp',
			'src/module-resources.cpp',
		],
		
		# Engine LCB files containing syntax
		'engine_syntax_lcb_files':
		[
			'src/canvas.mlc',
			'src/engine.mlc',
			'src/widget.mlc',
		],
		
		# Other engine LCB files
		'engine_other_lcb_files':
		[
		
		],
	},
	
	'target_defaults':
	{
		'include_dirs':
		[
			'>(INTERMEDIATE_DIR)/src',
			'>(INTERMEDIATE_DIR)/include',
			'>(SHARED_INTERMEDIATE_DIR)/src',
			'>(SHARED_INTERMEDIATE_DIR)/include',
		],
		
		# These files get included rather than compiled directly
		'sources!':
		[
			'src/rgb.cpp',
			'src/ports.cpp',
			'src/icondata.cpp',
			'src/props.cpp',
		],
	
		# Engine has some additional exclusion patterns that need to be applied
		'conditions':
		[
			[
				'OS != "mac"',
				{
					'sources/':
					[
						['exclude', '(^|/)sysosx.*\\.(cpp|mm)$'],
						['exclude', '\\.mac\\.'],
						['exclude', '(^|/)mac-'],
					],
					
					'sources!':
					[
						'src/dskmac.cpp',
						'src/srvmac.cpp',
					],
				},
			],
			[
				'OS != "linux"',
				{
					'sources/':
					[
						['exclude', '(^|/)dsklnx.*\\.cpp$'],
						['exclude', '(^|/)syslnx.*\\.cpp$'],
						['exclude', '(^|/)linux-'],
					],
				},
			],
			[
				'OS != "win"',
				{
					'sources/':
					[
						['exclude', '(^|/)sysw32.*\\.cpp$'],
						['exclude', '(^|/)dskw32.*\\.cpp$'],
						['exclude', '(^|/)win(dows|32)?-'],
					],
					
					'sources!':
					[
						'src/srvwindows.cpp',
					],
				},
			],
			[
				'OS != "emscripten"',
				{
					'sources/':
					[
						['exclude', '(^|/)em-.*\\.cpp$'],
					],
				},
			],
			[
				'OS == "win"',
				{
					'sources/':
					[
						['exclude', '(^|/)sysunx.*\\.cpp$'],
					],
					
					'sources!':
					[
						'src/fiber.cpp',
						'src/player-platform.cpp',
						'src/tilecachegl.cpp',
					],
				},
			],
			
			[
				'OS == "mac"',
				{
					'sources!':
					[
						'src/tilecachegl.cpp',
						'src/player-platform.cpp',
						'src/sysunxrandom.cpp',
						'src/sysunxregion.cpp',
						'src/sysunxdate.cpp',
						
						'src/srvflst.cpp',
					],
				},
				{
					'sources!':
					[
						
						'src/desktop.cpp',
						'src/desktop-ans.cpp',
						'src/desktop-dc.cpp',
						'src/desktop-image.cpp',
						'src/desktop-menu.cpp',
						'src/desktop-pasteboard.cpp',
						'src/desktop-stack.cpp',
						'src/platform.cpp',
						'src/platform-recorder.cpp',
						'src/platform-surface.cpp',
						'src/platform-window.cpp',
					],
				},
			],
			[
				'OS != "mac" and OS != "ios"',
				{
					'sources!':
					[
						'src/cgimageutil.cpp',
						'src/coretextfonts.cpp',
						'src/syscfdate.cpp',
						'src/tilecachecg.cpp',
					],
				},
			],
			[
				'OS == "linux"',
				{
					'sources!':
					[
						'src/player-platform.cpp',
						'src/tilecachegl.cpp',
					]
				},
			],
			[
				'OS == "android"',
				{
					'sources!':
					[
						'src/player-platform.cpp',
						'src/sysunxnetwork.cpp',
					],
				},
			],
			[
				'OS == "ios"',
				{
					'sources!':
					[
						'src/stacke.cpp',
						'src/sysunxdate.cpp',
						'src/sysunxrandom.cpp',
						
						'src/mbliphoneembedded.mm',
						'src/mbliphoneembeddedtest.mm',
					],
				},
			],
			[
				'OS != "linux" and OS != "mac"',
				{
					'sources!':
					[
						'src/srvposix.cpp',
					],
				},
			],
			[
				'OS == "emscripten"',
				{
					'sources!':
					[
						'src/tilecachegl.cpp',
						'src/mcssl.cpp',
						'src/path.cpp',
						'src/pathgray.cpp',
						'src/pathprocess.cpp',
					],
				},
			],
			[
				'mobile != 0',
				{
					'sources/':
					[
						# Note that this does *not* exclude player.cpp
						['exclude', '^src/player.+\\.(cpp|mm)$'],
						['exclude', '^src/dsk.*\\.(cpp|mm)$'],
					],
				},
			],
		],
	},
}
