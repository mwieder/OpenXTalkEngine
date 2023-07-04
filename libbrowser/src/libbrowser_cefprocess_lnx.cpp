/* Copyright (C) 2015 LiveCode Ltd.
 
 This file is part of LiveCode.
 
 LiveCode is free software; you can redistribute it and/or modify it under
 the terms of the GNU General Public License v3 as published by the Free
 Software Foundation.
 
 LiveCode is distributed in the hope that it will be useful, but WITHOUT ANY
 WARRANTY; without even the implied warranty of MERCHANTABILITY or
 FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 for more details.
 
 You should have received a copy of the GNU General Public License
 along with LiveCode.  If not see <http://www.gnu.org/licenses/>.  */

#include <include/cef_app.h>

#include "core.h"
#include "libbrowser_cef.h"

////////////////////////////////////////////////////////////////////////////////

extern bool MCCefCreateApp(CefRefPtr<CefApp> &r_app);

////////////////////////////////////////////////////////////////////////////////

extern "C" int initialise_weak_link_cef(void);
extern "C" int initialise_weak_link_cef_with_path(const char *p_path);
extern "C" int initialise_weak_link_X11(void);


int main(int argc, char *argv[])
{
	const char *t_lib_path;
	t_lib_path = MCCefPlatformGetCefLibraryPath();
	
#if !defined(BUILDING_CEFPROCESS)
    // We need to call some Xlib functions directly
    if (!initialise_weak_link_X11())
        return -1;
#endif

	// IM-2014-03-18: [[ revBrowserCEF ]] Initialise dynamically loaded cef library
	if (t_lib_path != nil)
	{
		MCLog("lib path: %s", t_lib_path);
		if (!initialise_weak_link_cef_with_path(t_lib_path))
			return -1;
	}
	else
	{
		if (!initialise_weak_link_cef())
			return -1;
	}

	MCLog("constructing args", nil);
	CefMainArgs t_args(argc, argv);
	
	MCLog("constructing args", nil);
	CefMainArgs t_args(argc, argv);

	MCLog("creating app", nil);
	CefRefPtr<CefApp> t_app;
	if (!MCCefCreateApp(t_app))
		return -1;
	
	MCLog("executing", nil);
	return CefExecuteProcess(t_args, t_app, NULL);
}

////////////////////////////////////////////////////////////////////////////////

bool MCCefPlatformEnableHiDPI(void)
{
	return true;
}

////////////////////////////////////////////////////////////////////////////////

