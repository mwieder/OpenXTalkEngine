#include <stdlib.h>
#include <stdio.h>
#include <cstring>

#define SYMBOL_PREFIX

typedef void *module_t;
typedef void *handler_t;

#ifdef _DEBUG
#include <stdint.h>
extern void __MCLog(const char *file, uint32_t line, const char *format, ...);
#define MCLog(...) __MCLog(__FILE__, __LINE__, __VA_ARGS__)
#else
#define MCLog(...) (void) (__VA_ARGS__)
#endif
extern "C" void *MCSupportLibraryLoad(const char *);
extern "C" void MCSupportLibraryUnload(void *);
extern "C" void *MCSupportLibraryLookupSymbol(void *, const char *);

extern "C"
{

static int module_load(const char *p_source, module_t *r_module)
{
  module_t t_module;
 	t_module = (module_t)MCSupportLibraryLoad(p_source);
  if (t_module == NULL)
    return 0;
  *r_module = t_module;
  return 1;
}

static int module_unload(module_t p_module)
{
  MCSupportLibraryUnload(p_module);
  return 1;
}

static int module_resolve(module_t p_module, const char *p_name, handler_t *r_handler)
{
  handler_t t_handler;
    t_handler = MCSupportLibraryLookupSymbol(p_module, p_name);
  if (t_handler == NULL)
    return 0;
  *r_handler = t_handler;
  return 1;
}


#if defined(_LINUX)
static void failed_required_link(const char* libname, const char* liblist)
{
  const char* dialog =
    "zenity --error --title \"$TITLE\" --text \"$TEXT\" 2>/dev/null 1>/dev/null && "
    "echo \"wm state . withdrawn ; tk_messageBox -icon error -message \\\"$TEXT\\\" -title \\\"$TITLE\\\" -type ok ; exit \" | wish && "
    "xmessage -center -buttons OK -default OK \"$TITLE:\" \"$TEXT\"" 
	;

  char* error = new char[65536];
  char* command = new char[65536];

  snprintf(error, 65536, "Failed to load library \'%s\' (tried %s)", libname, liblist);
  snprintf(command, 65536, "TITLE=\"LiveCode startup error\" TEXT=\"%s\" /bin/sh -c \'%s\' &", error, dialog);
  MCLog( "Fatal: failed to load library \'%s\' (tried %s)\n", libname, liblist);
  int ignored = system(command); (void)ignored;
  exit(-1);
}
#endif

typedef int (*CDSequenceEnd_t)(int pArg0);
CDSequenceEnd_t CDSequenceEnd_ptr = NULL;
typedef int (*CDSequenceNewDataSource_t)(int pArg0, void *pArg1, int pArg2, int pArg3, void *pArg4, void *pArg5, void *pArg6);
CDSequenceNewDataSource_t CDSequenceNewDataSource_ptr = NULL;
typedef int (*CDSequenceSetSourceData_t)(int pArg0, void *pArg1, int pArg2);
CDSequenceSetSourceData_t CDSequenceSetSourceData_ptr = NULL;
typedef int (*CDSequenceSetTimeBase_t)(int pArg0, void *pArg1);
CDSequenceSetTimeBase_t CDSequenceSetTimeBase_ptr = NULL;
typedef int (*ConvertMovieToDataRef_t)(void *pArg0, void *pArg1, void *pArg2, int pArg3, int pArg4, int pArg5, int pArg6, void *pArg7);
ConvertMovieToDataRef_t ConvertMovieToDataRef_ptr = NULL;
typedef int (*DecompressSequenceBeginS_t)(void *pArg0, void *pArg1, void *pArg2, int pArg3, void *pArg4, void *pArg5, void *pArg6, void *pArg7, int pArg8, void *pArg9, int pArg10, int pArg11, void *pArg12);
DecompressSequenceBeginS_t DecompressSequenceBeginS_ptr = NULL;
typedef int (*DecompressSequenceFrameWhen_t)(int pArg0, void *pArg1, int pArg2, int pArg3, void *pArg4, void *pArg5, void *pArg6);
DecompressSequenceFrameWhen_t DecompressSequenceFrameWhen_ptr = NULL;
typedef void (*DisposeMovie_t)(void *pArg0);
DisposeMovie_t DisposeMovie_ptr = NULL;
typedef void (*DisposeTimeBase_t)(void *pArg0);
DisposeTimeBase_t DisposeTimeBase_ptr = NULL;
typedef int (*EnterMovies_t)(void);
EnterMovies_t EnterMovies_ptr = NULL;
typedef void *(*GetMediaHandler_t)(void *pArg0);
GetMediaHandler_t GetMediaHandler_ptr = NULL;
typedef void (*GetMediaHandlerDescription_t)(void *pArg0, void *pArg1, void *pArg2, void *pArg3);
GetMediaHandlerDescription_t GetMediaHandlerDescription_ptr = NULL;
typedef void (*GetMediaSampleDescription_t)(void *pArg0, int pArg1, void *pArg2);
GetMediaSampleDescription_t GetMediaSampleDescription_ptr = NULL;
typedef void *(*GetMovieIndTrack_t)(void *pArg0, int pArg1);
GetMovieIndTrack_t GetMovieIndTrack_ptr = NULL;
typedef void *(*GetMovieIndTrackType_t)(void *pArg0, int pArg1, int pArg2, int pArg3);
GetMovieIndTrackType_t GetMovieIndTrackType_ptr = NULL;
typedef int (*GetMovieTrackCount_t)(void *pArg0);
GetMovieTrackCount_t GetMovieTrackCount_ptr = NULL;
typedef void *(*GetMovieUserData_t)(void *pArg0);
GetMovieUserData_t GetMovieUserData_ptr = NULL;
typedef int (*GetMovieVisualContext_t)(void *pArg0, void *pArg1);
GetMovieVisualContext_t GetMovieVisualContext_ptr = NULL;
typedef int (*GetMoviesError_t)(void);
GetMoviesError_t GetMoviesError_ptr = NULL;
typedef int (*GetTrackDuration_t)(void *pArg0);
GetTrackDuration_t GetTrackDuration_ptr = NULL;
typedef int (*GetTrackEnabled_t)(void *pArg0);
GetTrackEnabled_t GetTrackEnabled_ptr = NULL;
typedef int (*GetTrackID_t)(void *pArg0);
GetTrackID_t GetTrackID_ptr = NULL;
typedef void *(*GetTrackMedia_t)(void *pArg0);
GetTrackMedia_t GetTrackMedia_ptr = NULL;
typedef int (*GetTrackOffset_t)(void *pArg0);
GetTrackOffset_t GetTrackOffset_ptr = NULL;
typedef int (*GetUserDataItem_t)(void *pArg0, void *pArg1, int pArg2, int pArg3, int pArg4);
GetUserDataItem_t GetUserDataItem_ptr = NULL;
typedef int (*MCMovieChanged_t)(void *pArg0, void *pArg1);
MCMovieChanged_t MCMovieChanged_ptr = NULL;
typedef int (*MCSetActionFilterWithRefCon_t)(void *pArg0, void *pArg1, int pArg2);
MCSetActionFilterWithRefCon_t MCSetActionFilterWithRefCon_ptr = NULL;
typedef int (*MakeImageDescriptionForEffect_t)(int pArg0, void *pArg1);
MakeImageDescriptionForEffect_t MakeImageDescriptionForEffect_ptr = NULL;
typedef int (*MakeImageDescriptionForPixMap_t)(void *pArg0, void *pArg1);
MakeImageDescriptionForPixMap_t MakeImageDescriptionForPixMap_ptr = NULL;
typedef int (*MediaGetName_t)(void *pArg0, void *pArg1, int pArg2, void *pArg3);
MediaGetName_t MediaGetName_ptr = NULL;
typedef int (*MovieExportSetSampleDescription_t)(void *pArg0, void *pArg1, int pArg2);
MovieExportSetSampleDescription_t MovieExportSetSampleDescription_ptr = NULL;
typedef int (*NewMovieFromProperties_t)(int pArg0, void *pArg1, int pArg2, void *pArg3, void *pArg4);
NewMovieFromProperties_t NewMovieFromProperties_ptr = NULL;
typedef void *(*NewTimeBase_t)(void);
NewTimeBase_t NewTimeBase_ptr = NULL;
typedef int (*QTCopyAtomDataToPtr_t)(void *pArg0, int pArg1, int pArg2, int pArg3, void *pArg4, void *pArg5);
QTCopyAtomDataToPtr_t QTCopyAtomDataToPtr_ptr = NULL;
typedef int (*QTCountChildrenOfType_t)(void *pArg0, int pArg1, int pArg2);
QTCountChildrenOfType_t QTCountChildrenOfType_ptr = NULL;
typedef int (*QTCreateStandardParameterDialog_t)(void *pArg0, void *pArg1, int pArg2, void *pArg3);
QTCreateStandardParameterDialog_t QTCreateStandardParameterDialog_ptr = NULL;
typedef int (*QTDismissStandardParameterDialog_t)(int pArg0);
QTDismissStandardParameterDialog_t QTDismissStandardParameterDialog_ptr = NULL;
typedef int (*QTDisposeAtomContainer_t)(void *pArg0);
QTDisposeAtomContainer_t QTDisposeAtomContainer_ptr = NULL;
typedef int (*QTFindChildByID_t)(void *pArg0, int pArg1, int pArg2, int pArg3, void *pArg4);
QTFindChildByID_t QTFindChildByID_ptr = NULL;
typedef int (*QTFindChildByIndex_t)(void *pArg0, int pArg1, int pArg2, int pArg3, void *pArg4);
QTFindChildByIndex_t QTFindChildByIndex_ptr = NULL;
typedef int (*QTGetAtomDataPtr_t)(void *pArg0, int pArg1, void *pArg2, void *pArg3);
QTGetAtomDataPtr_t QTGetAtomDataPtr_ptr = NULL;
typedef int (*QTGetComponentProperty_t)(void *pArg0, int pArg1, int pArg2, int pArg3, void *pArg4, void *pArg5);
QTGetComponentProperty_t QTGetComponentProperty_ptr = NULL;
typedef int (*QTGetComponentPropertyInfo_t)(void *pArg0, int pArg1, int pArg2, void *pArg3, void *pArg4, void *pArg5);
QTGetComponentPropertyInfo_t QTGetComponentPropertyInfo_ptr = NULL;
typedef int (*QTGetEffectsList_t)(void *pArg0, int pArg1, int pArg2, int pArg3);
QTGetEffectsList_t QTGetEffectsList_ptr = NULL;
typedef int (*QTGetPixMapHandleRowBytes_t)(void *pArg0);
QTGetPixMapHandleRowBytes_t QTGetPixMapHandleRowBytes_ptr = NULL;
typedef int (*QTInsertChild_t)(void *pArg0, int pArg1, int pArg2, int pArg3, int pArg4, int pArg5, void *pArg6, void *pArg7);
QTInsertChild_t QTInsertChild_ptr = NULL;
typedef int (*QTIsStandardParameterDialogEvent_t)(void *pArg0, int pArg1);
QTIsStandardParameterDialogEvent_t QTIsStandardParameterDialogEvent_ptr = NULL;
typedef int (*QTLockContainer_t)(void *pArg0);
QTLockContainer_t QTLockContainer_ptr = NULL;
typedef int (*QTNewAtomContainer_t)(void *pArg0);
QTNewAtomContainer_t QTNewAtomContainer_ptr = NULL;
typedef int (*QTNewDataReferenceFromFullPathCFString_t)(void *pArg0, int pArg1, int pArg2, void *pArg3, void *pArg4);
QTNewDataReferenceFromFullPathCFString_t QTNewDataReferenceFromFullPathCFString_ptr = NULL;
typedef int (*QTNewGWorld_t)(void *pArg0, int pArg1, void *pArg2, void *pArg3, void *pArg4, int pArg5);
QTNewGWorld_t QTNewGWorld_ptr = NULL;
typedef int (*QTNewGWorldFromPtr_t)(void *pArg0, int pArg1, void *pArg2, void *pArg3, void *pArg4, int pArg5, void *pArg6, int pArg7);
QTNewGWorldFromPtr_t QTNewGWorldFromPtr_ptr = NULL;
typedef int (*QTSetComponentProperty_t)(void *pArg0, int pArg1, int pArg2, int pArg3, void *pArg4);
QTSetComponentProperty_t QTSetComponentProperty_ptr = NULL;
typedef int (*QTSwapAtoms_t)(void *pArg0, int pArg1, int pArg2);
QTSwapAtoms_t QTSwapAtoms_ptr = NULL;
typedef int (*QTUnlockContainer_t)(void *pArg0);
QTUnlockContainer_t QTUnlockContainer_ptr = NULL;
typedef int (*QTVisualContextCopyImageForTime_t)(void *pArg0, void *pArg1, void *pArg2, void *pArg3);
QTVisualContextCopyImageForTime_t QTVisualContextCopyImageForTime_ptr = NULL;
typedef void (*RectMatrix_t)(void *pArg0, void *pArg1, void *pArg2);
RectMatrix_t RectMatrix_ptr = NULL;
typedef int (*SCGetInfo_t)(void *pArg0, int pArg1, void *pArg2);
SCGetInfo_t SCGetInfo_ptr = NULL;
typedef int (*SCRequestImageSettings_t)(void *pArg0);
SCRequestImageSettings_t SCRequestImageSettings_ptr = NULL;
typedef int (*SCSetInfo_t)(void *pArg0, int pArg1, void *pArg2);
SCSetInfo_t SCSetInfo_ptr = NULL;
typedef int (*SGDisposeChannel_t)(void *pArg0, void *pArg1);
SGDisposeChannel_t SGDisposeChannel_ptr = NULL;
typedef int (*SGGetSoundInputDriver_t)(void *pArg0);
SGGetSoundInputDriver_t SGGetSoundInputDriver_ptr = NULL;
typedef int (*SGIdle_t)(void *pArg0);
SGIdle_t SGIdle_ptr = NULL;
typedef int (*SGInitialize_t)(void *pArg0);
SGInitialize_t SGInitialize_ptr = NULL;
typedef int (*SGNewChannel_t)(void *pArg0, int pArg1, void *pArg2);
SGNewChannel_t SGNewChannel_ptr = NULL;
typedef int (*SGPause_t)(void *pArg0, int pArg1);
SGPause_t SGPause_ptr = NULL;
typedef int (*SGSetChannelUsage_t)(void *pArg0, int pArg1);
SGSetChannelUsage_t SGSetChannelUsage_ptr = NULL;
typedef int (*SGSetDataOutput_t)(void *pArg0, void *pArg1, int pArg2);
SGSetDataOutput_t SGSetDataOutput_ptr = NULL;
typedef int (*SGSetDataRef_t)(void *pArg0, void *pArg1, int pArg2, int pArg3);
SGSetDataRef_t SGSetDataRef_ptr = NULL;
typedef int (*SGSetSoundInputParameters_t)(void *pArg0, int pArg1, int pArg2, int pArg3);
SGSetSoundInputParameters_t SGSetSoundInputParameters_ptr = NULL;
typedef int (*SGSetSoundInputRate_t)(void *pArg0, int pArg1);
SGSetSoundInputRate_t SGSetSoundInputRate_ptr = NULL;
typedef int (*SGSoundInputDriverChanged_t)(void *pArg0);
SGSoundInputDriverChanged_t SGSoundInputDriverChanged_ptr = NULL;
typedef int (*SGStartRecord_t)(void *pArg0);
SGStartRecord_t SGStartRecord_ptr = NULL;
typedef int (*SGStop_t)(void *pArg0);
SGStop_t SGStop_ptr = NULL;
typedef void (*SetMovieDrawingCompleteProc_t)(void *pArg0, int pArg1, void *pArg2, int pArg3);
SetMovieDrawingCompleteProc_t SetMovieDrawingCompleteProc_ptr = NULL;
typedef void (*SetTimeBaseRate_t)(void *pArg0, int pArg1);
SetTimeBaseRate_t SetTimeBaseRate_ptr = NULL;
typedef void (*SetTimeBaseValue_t)(void *pArg0, int pArg1, int pArg2);
SetTimeBaseValue_t SetTimeBaseValue_ptr = NULL;
typedef void (*SetTrackEnabled_t)(void *pArg0, int pArg1);
SetTrackEnabled_t SetTrackEnabled_ptr = NULL;
typedef void (*MoviesTask_t)(void *pArg0, int pArg1);
MoviesTask_t MoviesTask_ptr = NULL;

#if defined(_MACOSX) || defined(TARGET_SUBPLATFORM_IPHONE)
#define MODULE_QUICKTIME_NAME "/System/Library/Frameworks/QuickTime.framework/QuickTime"
#elif defined(_LINUX) || defined(__EMSCRIPTEN__)
#define MODULE_QUICKTIME_NAME "none"
#elif defined(TARGET_SUBPLATFORM_ANDROID)
#define MODULE_QUICKTIME_NAME "none"
#elif defined(_WINDOWS)
#define MODULE_QUICKTIME_NAME "none"
#endif

static module_t module_QuickTime = NULL;

void finalise_weak_link_QuickTime(void)
{
  module_unload(module_QuickTime);
  module_QuickTime = NULL;
}

int initialise_weak_link_QuickTime_with_path(const char *p_path)
{
  module_QuickTime = NULL;
  if (!module_load(p_path, &module_QuickTime))
  {
  #ifdef _DEBUG
    MCLog( "Unable to load library: %s\n", p_path);
  #endif
    goto err;
  }
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "CDSequenceEnd", (handler_t *)&CDSequenceEnd_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: CDSequenceEnd\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "CDSequenceNewDataSource", (handler_t *)&CDSequenceNewDataSource_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: CDSequenceNewDataSource\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "CDSequenceSetSourceData", (handler_t *)&CDSequenceSetSourceData_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: CDSequenceSetSourceData\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "CDSequenceSetTimeBase", (handler_t *)&CDSequenceSetTimeBase_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: CDSequenceSetTimeBase\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "ConvertMovieToDataRef", (handler_t *)&ConvertMovieToDataRef_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: ConvertMovieToDataRef\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "DecompressSequenceBeginS", (handler_t *)&DecompressSequenceBeginS_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: DecompressSequenceBeginS\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "DecompressSequenceFrameWhen", (handler_t *)&DecompressSequenceFrameWhen_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: DecompressSequenceFrameWhen\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "DisposeMovie", (handler_t *)&DisposeMovie_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: DisposeMovie\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "DisposeTimeBase", (handler_t *)&DisposeTimeBase_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: DisposeTimeBase\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "EnterMovies", (handler_t *)&EnterMovies_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: EnterMovies\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "GetMediaHandler", (handler_t *)&GetMediaHandler_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: GetMediaHandler\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "GetMediaHandlerDescription", (handler_t *)&GetMediaHandlerDescription_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: GetMediaHandlerDescription\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "GetMediaSampleDescription", (handler_t *)&GetMediaSampleDescription_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: GetMediaSampleDescription\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "GetMovieIndTrack", (handler_t *)&GetMovieIndTrack_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: GetMovieIndTrack\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "GetMovieIndTrackType", (handler_t *)&GetMovieIndTrackType_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: GetMovieIndTrackType\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "GetMovieTrackCount", (handler_t *)&GetMovieTrackCount_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: GetMovieTrackCount\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "GetMovieUserData", (handler_t *)&GetMovieUserData_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: GetMovieUserData\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "GetMovieVisualContext", (handler_t *)&GetMovieVisualContext_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: GetMovieVisualContext\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "GetMoviesError", (handler_t *)&GetMoviesError_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: GetMoviesError\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "GetTrackDuration", (handler_t *)&GetTrackDuration_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: GetTrackDuration\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "GetTrackEnabled", (handler_t *)&GetTrackEnabled_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: GetTrackEnabled\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "GetTrackID", (handler_t *)&GetTrackID_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: GetTrackID\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "GetTrackMedia", (handler_t *)&GetTrackMedia_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: GetTrackMedia\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "GetTrackOffset", (handler_t *)&GetTrackOffset_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: GetTrackOffset\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "GetUserDataItem", (handler_t *)&GetUserDataItem_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: GetUserDataItem\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "MCMovieChanged", (handler_t *)&MCMovieChanged_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: MCMovieChanged\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "MCSetActionFilterWithRefCon", (handler_t *)&MCSetActionFilterWithRefCon_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: MCSetActionFilterWithRefCon\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "MakeImageDescriptionForEffect", (handler_t *)&MakeImageDescriptionForEffect_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: MakeImageDescriptionForEffect\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "MakeImageDescriptionForPixMap", (handler_t *)&MakeImageDescriptionForPixMap_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: MakeImageDescriptionForPixMap\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "MediaGetName", (handler_t *)&MediaGetName_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: MediaGetName\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "MovieExportSetSampleDescription", (handler_t *)&MovieExportSetSampleDescription_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: MovieExportSetSampleDescription\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "NewMovieFromProperties", (handler_t *)&NewMovieFromProperties_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: NewMovieFromProperties\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "NewTimeBase", (handler_t *)&NewTimeBase_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: NewTimeBase\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "QTCopyAtomDataToPtr", (handler_t *)&QTCopyAtomDataToPtr_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTCopyAtomDataToPtr\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "QTCountChildrenOfType", (handler_t *)&QTCountChildrenOfType_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTCountChildrenOfType\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "QTCreateStandardParameterDialog", (handler_t *)&QTCreateStandardParameterDialog_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTCreateStandardParameterDialog\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "QTDismissStandardParameterDialog", (handler_t *)&QTDismissStandardParameterDialog_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTDismissStandardParameterDialog\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "QTDisposeAtomContainer", (handler_t *)&QTDisposeAtomContainer_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTDisposeAtomContainer\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "QTFindChildByID", (handler_t *)&QTFindChildByID_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTFindChildByID\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "QTFindChildByIndex", (handler_t *)&QTFindChildByIndex_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTFindChildByIndex\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "QTGetAtomDataPtr", (handler_t *)&QTGetAtomDataPtr_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTGetAtomDataPtr\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "QTGetComponentProperty", (handler_t *)&QTGetComponentProperty_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTGetComponentProperty\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "QTGetComponentPropertyInfo", (handler_t *)&QTGetComponentPropertyInfo_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTGetComponentPropertyInfo\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "QTGetEffectsList", (handler_t *)&QTGetEffectsList_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTGetEffectsList\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "QTGetPixMapHandleRowBytes", (handler_t *)&QTGetPixMapHandleRowBytes_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTGetPixMapHandleRowBytes\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "QTInsertChild", (handler_t *)&QTInsertChild_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTInsertChild\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "QTIsStandardParameterDialogEvent", (handler_t *)&QTIsStandardParameterDialogEvent_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTIsStandardParameterDialogEvent\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "QTLockContainer", (handler_t *)&QTLockContainer_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTLockContainer\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "QTNewAtomContainer", (handler_t *)&QTNewAtomContainer_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTNewAtomContainer\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "QTNewDataReferenceFromFullPathCFString", (handler_t *)&QTNewDataReferenceFromFullPathCFString_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTNewDataReferenceFromFullPathCFString\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "QTNewGWorld", (handler_t *)&QTNewGWorld_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTNewGWorld\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "QTNewGWorldFromPtr", (handler_t *)&QTNewGWorldFromPtr_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTNewGWorldFromPtr\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "QTSetComponentProperty", (handler_t *)&QTSetComponentProperty_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTSetComponentProperty\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "QTSwapAtoms", (handler_t *)&QTSwapAtoms_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTSwapAtoms\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "QTUnlockContainer", (handler_t *)&QTUnlockContainer_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTUnlockContainer\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "QTVisualContextCopyImageForTime", (handler_t *)&QTVisualContextCopyImageForTime_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTVisualContextCopyImageForTime\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "RectMatrix", (handler_t *)&RectMatrix_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: RectMatrix\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "SCGetInfo", (handler_t *)&SCGetInfo_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: SCGetInfo\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "SCRequestImageSettings", (handler_t *)&SCRequestImageSettings_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: SCRequestImageSettings\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "SCSetInfo", (handler_t *)&SCSetInfo_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: SCSetInfo\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "SGDisposeChannel", (handler_t *)&SGDisposeChannel_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: SGDisposeChannel\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "SGGetSoundInputDriver", (handler_t *)&SGGetSoundInputDriver_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: SGGetSoundInputDriver\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "SGIdle", (handler_t *)&SGIdle_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: SGIdle\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "SGInitialize", (handler_t *)&SGInitialize_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: SGInitialize\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "SGNewChannel", (handler_t *)&SGNewChannel_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: SGNewChannel\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "SGPause", (handler_t *)&SGPause_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: SGPause\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "SGSetChannelUsage", (handler_t *)&SGSetChannelUsage_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: SGSetChannelUsage\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "SGSetDataOutput", (handler_t *)&SGSetDataOutput_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: SGSetDataOutput\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "SGSetDataRef", (handler_t *)&SGSetDataRef_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: SGSetDataRef\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "SGSetSoundInputParameters", (handler_t *)&SGSetSoundInputParameters_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: SGSetSoundInputParameters\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "SGSetSoundInputRate", (handler_t *)&SGSetSoundInputRate_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: SGSetSoundInputRate\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "SGSoundInputDriverChanged", (handler_t *)&SGSoundInputDriverChanged_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: SGSoundInputDriverChanged\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "SGStartRecord", (handler_t *)&SGStartRecord_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: SGStartRecord\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "SGStop", (handler_t *)&SGStop_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: SGStop\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "SetMovieDrawingCompleteProc", (handler_t *)&SetMovieDrawingCompleteProc_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: SetMovieDrawingCompleteProc\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "SetTimeBaseRate", (handler_t *)&SetTimeBaseRate_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: SetTimeBaseRate\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "SetTimeBaseValue", (handler_t *)&SetTimeBaseValue_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: SetTimeBaseValue\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "SetTrackEnabled", (handler_t *)&SetTrackEnabled_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: SetTrackEnabled\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickTime, SYMBOL_PREFIX "MoviesTask", (handler_t *)&MoviesTask_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: MoviesTask\n");
#endif
goto err; 
}

  return 1;

err:
  if (module_QuickTime != NULL)
    module_unload(module_QuickTime);

  return 0;
}

int initialise_weak_link_QuickTime(void)
{
#if defined(_LINUX)
  if(!initialise_weak_link_QuickTime_with_path("none"))
#else
  if (!initialise_weak_link_QuickTime_with_path(MODULE_QUICKTIME_NAME))
#endif
{
#ifdef _DEBUG
    MCLog( "Warning: could not load library: none\n");
#endif
return 0;
}
return -1;
}

#if defined(_LINUX)
void initialise_required_weak_link_QuickTime(void)
{
  if (!initialise_weak_link_QuickTime())
  {
    failed_required_link("QuickTime", "none");
  }
}
#endif

int CDSequenceEnd(int pArg0)
{
  return CDSequenceEnd_ptr(pArg0);
}

int CDSequenceNewDataSource(int pArg0, void *pArg1, int pArg2, int pArg3, void *pArg4, void *pArg5, void *pArg6)
{
  return CDSequenceNewDataSource_ptr(pArg0, pArg1, pArg2, pArg3, pArg4, pArg5, pArg6);
}

int CDSequenceSetSourceData(int pArg0, void *pArg1, int pArg2)
{
  return CDSequenceSetSourceData_ptr(pArg0, pArg1, pArg2);
}

int CDSequenceSetTimeBase(int pArg0, void *pArg1)
{
  return CDSequenceSetTimeBase_ptr(pArg0, pArg1);
}

int ConvertMovieToDataRef(void *pArg0, void *pArg1, void *pArg2, int pArg3, int pArg4, int pArg5, int pArg6, void *pArg7)
{
  return ConvertMovieToDataRef_ptr(pArg0, pArg1, pArg2, pArg3, pArg4, pArg5, pArg6, pArg7);
}

int DecompressSequenceBeginS(void *pArg0, void *pArg1, void *pArg2, int pArg3, void *pArg4, void *pArg5, void *pArg6, void *pArg7, int pArg8, void *pArg9, int pArg10, int pArg11, void *pArg12)
{
  return DecompressSequenceBeginS_ptr(pArg0, pArg1, pArg2, pArg3, pArg4, pArg5, pArg6, pArg7, pArg8, pArg9, pArg10, pArg11, pArg12);
}

int DecompressSequenceFrameWhen(int pArg0, void *pArg1, int pArg2, int pArg3, void *pArg4, void *pArg5, void *pArg6)
{
  return DecompressSequenceFrameWhen_ptr(pArg0, pArg1, pArg2, pArg3, pArg4, pArg5, pArg6);
}

void DisposeMovie(void *pArg0)
{
  DisposeMovie_ptr(pArg0);
}

void DisposeTimeBase(void *pArg0)
{
  DisposeTimeBase_ptr(pArg0);
}

int EnterMovies(void)
{
  return EnterMovies_ptr();
}

void *GetMediaHandler(void *pArg0)
{
  return GetMediaHandler_ptr(pArg0);
}

void GetMediaHandlerDescription(void *pArg0, void *pArg1, void *pArg2, void *pArg3)
{
  GetMediaHandlerDescription_ptr(pArg0, pArg1, pArg2, pArg3);
}

void GetMediaSampleDescription(void *pArg0, int pArg1, void *pArg2)
{
  GetMediaSampleDescription_ptr(pArg0, pArg1, pArg2);
}

void *GetMovieIndTrack(void *pArg0, int pArg1)
{
  return GetMovieIndTrack_ptr(pArg0, pArg1);
}

void *GetMovieIndTrackType(void *pArg0, int pArg1, int pArg2, int pArg3)
{
  return GetMovieIndTrackType_ptr(pArg0, pArg1, pArg2, pArg3);
}

int GetMovieTrackCount(void *pArg0)
{
  return GetMovieTrackCount_ptr(pArg0);
}

void *GetMovieUserData(void *pArg0)
{
  return GetMovieUserData_ptr(pArg0);
}

int GetMovieVisualContext(void *pArg0, void *pArg1)
{
  return GetMovieVisualContext_ptr(pArg0, pArg1);
}

int GetMoviesError(void)
{
  return GetMoviesError_ptr();
}

int GetTrackDuration(void *pArg0)
{
  return GetTrackDuration_ptr(pArg0);
}

int GetTrackEnabled(void *pArg0)
{
  return GetTrackEnabled_ptr(pArg0);
}

int GetTrackID(void *pArg0)
{
  return GetTrackID_ptr(pArg0);
}

void *GetTrackMedia(void *pArg0)
{
  return GetTrackMedia_ptr(pArg0);
}

int GetTrackOffset(void *pArg0)
{
  return GetTrackOffset_ptr(pArg0);
}

int GetUserDataItem(void *pArg0, void *pArg1, int pArg2, int pArg3, int pArg4)
{
  return GetUserDataItem_ptr(pArg0, pArg1, pArg2, pArg3, pArg4);
}

int MCMovieChanged(void *pArg0, void *pArg1)
{
  return MCMovieChanged_ptr(pArg0, pArg1);
}

int MCSetActionFilterWithRefCon(void *pArg0, void *pArg1, int pArg2)
{
  return MCSetActionFilterWithRefCon_ptr(pArg0, pArg1, pArg2);
}

int MakeImageDescriptionForEffect(int pArg0, void *pArg1)
{
  return MakeImageDescriptionForEffect_ptr(pArg0, pArg1);
}

int MakeImageDescriptionForPixMap(void *pArg0, void *pArg1)
{
  return MakeImageDescriptionForPixMap_ptr(pArg0, pArg1);
}

int MediaGetName(void *pArg0, void *pArg1, int pArg2, void *pArg3)
{
  return MediaGetName_ptr(pArg0, pArg1, pArg2, pArg3);
}

int MovieExportSetSampleDescription(void *pArg0, void *pArg1, int pArg2)
{
  return MovieExportSetSampleDescription_ptr(pArg0, pArg1, pArg2);
}

int NewMovieFromProperties(int pArg0, void *pArg1, int pArg2, void *pArg3, void *pArg4)
{
  return NewMovieFromProperties_ptr(pArg0, pArg1, pArg2, pArg3, pArg4);
}

void *NewTimeBase(void)
{
  return NewTimeBase_ptr();
}

int QTCopyAtomDataToPtr(void *pArg0, int pArg1, int pArg2, int pArg3, void *pArg4, void *pArg5)
{
  return QTCopyAtomDataToPtr_ptr(pArg0, pArg1, pArg2, pArg3, pArg4, pArg5);
}

int QTCountChildrenOfType(void *pArg0, int pArg1, int pArg2)
{
  return QTCountChildrenOfType_ptr(pArg0, pArg1, pArg2);
}

int QTCreateStandardParameterDialog(void *pArg0, void *pArg1, int pArg2, void *pArg3)
{
  return QTCreateStandardParameterDialog_ptr(pArg0, pArg1, pArg2, pArg3);
}

int QTDismissStandardParameterDialog(int pArg0)
{
  return QTDismissStandardParameterDialog_ptr(pArg0);
}

int QTDisposeAtomContainer(void *pArg0)
{
  return QTDisposeAtomContainer_ptr(pArg0);
}

int QTFindChildByID(void *pArg0, int pArg1, int pArg2, int pArg3, void *pArg4)
{
  return QTFindChildByID_ptr(pArg0, pArg1, pArg2, pArg3, pArg4);
}

int QTFindChildByIndex(void *pArg0, int pArg1, int pArg2, int pArg3, void *pArg4)
{
  return QTFindChildByIndex_ptr(pArg0, pArg1, pArg2, pArg3, pArg4);
}

int QTGetAtomDataPtr(void *pArg0, int pArg1, void *pArg2, void *pArg3)
{
  return QTGetAtomDataPtr_ptr(pArg0, pArg1, pArg2, pArg3);
}

int QTGetComponentProperty(void *pArg0, int pArg1, int pArg2, int pArg3, void *pArg4, void *pArg5)
{
  return QTGetComponentProperty_ptr(pArg0, pArg1, pArg2, pArg3, pArg4, pArg5);
}

int QTGetComponentPropertyInfo(void *pArg0, int pArg1, int pArg2, void *pArg3, void *pArg4, void *pArg5)
{
  return QTGetComponentPropertyInfo_ptr(pArg0, pArg1, pArg2, pArg3, pArg4, pArg5);
}

int QTGetEffectsList(void *pArg0, int pArg1, int pArg2, int pArg3)
{
  return QTGetEffectsList_ptr(pArg0, pArg1, pArg2, pArg3);
}

int QTGetPixMapHandleRowBytes(void *pArg0)
{
  return QTGetPixMapHandleRowBytes_ptr(pArg0);
}

int QTInsertChild(void *pArg0, int pArg1, int pArg2, int pArg3, int pArg4, int pArg5, void *pArg6, void *pArg7)
{
  return QTInsertChild_ptr(pArg0, pArg1, pArg2, pArg3, pArg4, pArg5, pArg6, pArg7);
}

int QTIsStandardParameterDialogEvent(void *pArg0, int pArg1)
{
  return QTIsStandardParameterDialogEvent_ptr(pArg0, pArg1);
}

int QTLockContainer(void *pArg0)
{
  return QTLockContainer_ptr(pArg0);
}

int QTNewAtomContainer(void *pArg0)
{
  return QTNewAtomContainer_ptr(pArg0);
}

int QTNewDataReferenceFromFullPathCFString(void *pArg0, int pArg1, int pArg2, void *pArg3, void *pArg4)
{
  return QTNewDataReferenceFromFullPathCFString_ptr(pArg0, pArg1, pArg2, pArg3, pArg4);
}

int QTNewGWorld(void *pArg0, int pArg1, void *pArg2, void *pArg3, void *pArg4, int pArg5)
{
  return QTNewGWorld_ptr(pArg0, pArg1, pArg2, pArg3, pArg4, pArg5);
}

int QTNewGWorldFromPtr(void *pArg0, int pArg1, void *pArg2, void *pArg3, void *pArg4, int pArg5, void *pArg6, int pArg7)
{
  return QTNewGWorldFromPtr_ptr(pArg0, pArg1, pArg2, pArg3, pArg4, pArg5, pArg6, pArg7);
}

int QTSetComponentProperty(void *pArg0, int pArg1, int pArg2, int pArg3, void *pArg4)
{
  return QTSetComponentProperty_ptr(pArg0, pArg1, pArg2, pArg3, pArg4);
}

int QTSwapAtoms(void *pArg0, int pArg1, int pArg2)
{
  return QTSwapAtoms_ptr(pArg0, pArg1, pArg2);
}

int QTUnlockContainer(void *pArg0)
{
  return QTUnlockContainer_ptr(pArg0);
}

int QTVisualContextCopyImageForTime(void *pArg0, void *pArg1, void *pArg2, void *pArg3)
{
  return QTVisualContextCopyImageForTime_ptr(pArg0, pArg1, pArg2, pArg3);
}

void RectMatrix(void *pArg0, void *pArg1, void *pArg2)
{
  RectMatrix_ptr(pArg0, pArg1, pArg2);
}

int SCGetInfo(void *pArg0, int pArg1, void *pArg2)
{
  return SCGetInfo_ptr(pArg0, pArg1, pArg2);
}

int SCRequestImageSettings(void *pArg0)
{
  return SCRequestImageSettings_ptr(pArg0);
}

int SCSetInfo(void *pArg0, int pArg1, void *pArg2)
{
  return SCSetInfo_ptr(pArg0, pArg1, pArg2);
}

int SGDisposeChannel(void *pArg0, void *pArg1)
{
  return SGDisposeChannel_ptr(pArg0, pArg1);
}

int SGGetSoundInputDriver(void *pArg0)
{
  return SGGetSoundInputDriver_ptr(pArg0);
}

int SGIdle(void *pArg0)
{
  return SGIdle_ptr(pArg0);
}

int SGInitialize(void *pArg0)
{
  return SGInitialize_ptr(pArg0);
}

int SGNewChannel(void *pArg0, int pArg1, void *pArg2)
{
  return SGNewChannel_ptr(pArg0, pArg1, pArg2);
}

int SGPause(void *pArg0, int pArg1)
{
  return SGPause_ptr(pArg0, pArg1);
}

int SGSetChannelUsage(void *pArg0, int pArg1)
{
  return SGSetChannelUsage_ptr(pArg0, pArg1);
}

int SGSetDataOutput(void *pArg0, void *pArg1, int pArg2)
{
  return SGSetDataOutput_ptr(pArg0, pArg1, pArg2);
}

int SGSetDataRef(void *pArg0, void *pArg1, int pArg2, int pArg3)
{
  return SGSetDataRef_ptr(pArg0, pArg1, pArg2, pArg3);
}

int SGSetSoundInputParameters(void *pArg0, int pArg1, int pArg2, int pArg3)
{
  return SGSetSoundInputParameters_ptr(pArg0, pArg1, pArg2, pArg3);
}

int SGSetSoundInputRate(void *pArg0, int pArg1)
{
  return SGSetSoundInputRate_ptr(pArg0, pArg1);
}

int SGSoundInputDriverChanged(void *pArg0)
{
  return SGSoundInputDriverChanged_ptr(pArg0);
}

int SGStartRecord(void *pArg0)
{
  return SGStartRecord_ptr(pArg0);
}

int SGStop(void *pArg0)
{
  return SGStop_ptr(pArg0);
}

void SetMovieDrawingCompleteProc(void *pArg0, int pArg1, void *pArg2, int pArg3)
{
  SetMovieDrawingCompleteProc_ptr(pArg0, pArg1, pArg2, pArg3);
}

void SetTimeBaseRate(void *pArg0, int pArg1)
{
  SetTimeBaseRate_ptr(pArg0, pArg1);
}

void SetTimeBaseValue(void *pArg0, int pArg1, int pArg2)
{
  SetTimeBaseValue_ptr(pArg0, pArg1, pArg2);
}

void SetTrackEnabled(void *pArg0, int pArg1)
{
  SetTrackEnabled_ptr(pArg0, pArg1);
}

void MoviesTask(void *pArg0, int pArg1)
{
  MoviesTask_ptr(pArg0, pArg1);
}

void *QTMovieSelectionDidChangeNotification_ptr = NULL;
void *QTMovieDidEndNotification_ptr = NULL;
void *QTMovieTimeDidChangeNotification_ptr = NULL;
void *QTMovieRateDidChangeNotification_ptr = NULL;
void *QTMakeTime_ptr = NULL;
void *QTMovieFileNameAttribute_ptr = NULL;
void *QTMovieLoopsAttribute_ptr = NULL;
void *QTMovieNaturalSizeAttribute_ptr = NULL;
void *QTMovieOpenAsyncOKAttribute_ptr = NULL;
void *QTMovieOpenAsyncRequiredAttribute_ptr = NULL;
void *QTMoviePlaysSelectionOnlyAttribute_ptr = NULL;
void *QTMovieURLAttribute_ptr = NULL;
void *QTTimeCompare_ptr = NULL;
void *QTMovieLoadStateAttribute_ptr = NULL;

#if defined(_MACOSX) || defined(TARGET_SUBPLATFORM_IPHONE)
#define MODULE_QTKIT_NAME "/System/Library/Frameworks/QTKit.framework/QTKit"
#elif defined(_LINUX) || defined(__EMSCRIPTEN__)
#define MODULE_QTKIT_NAME "none"
#elif defined(TARGET_SUBPLATFORM_ANDROID)
#define MODULE_QTKIT_NAME "none"
#elif defined(_WINDOWS)
#define MODULE_QTKIT_NAME "none"
#endif

static module_t module_QTKit = NULL;

void finalise_weak_link_QTKit(void)
{
  module_unload(module_QTKit);
  module_QTKit = NULL;
}

int initialise_weak_link_QTKit_with_path(const char *p_path)
{
  module_QTKit = NULL;
  if (!module_load(p_path, &module_QTKit))
  {
  #ifdef _DEBUG
    MCLog( "Unable to load library: %s\n", p_path);
  #endif
    goto err;
  }
  if (!module_resolve(module_QTKit, SYMBOL_PREFIX "QTMovieSelectionDidChangeNotification", (handler_t *)&QTMovieSelectionDidChangeNotification_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTMovieSelectionDidChangeNotification\n");
#endif
goto err; 
}
  if (!module_resolve(module_QTKit, SYMBOL_PREFIX "QTMovieDidEndNotification", (handler_t *)&QTMovieDidEndNotification_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTMovieDidEndNotification\n");
#endif
goto err; 
}
  if (!module_resolve(module_QTKit, SYMBOL_PREFIX "QTMovieTimeDidChangeNotification", (handler_t *)&QTMovieTimeDidChangeNotification_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTMovieTimeDidChangeNotification\n");
#endif
goto err; 
}
  if (!module_resolve(module_QTKit, SYMBOL_PREFIX "QTMovieRateDidChangeNotification", (handler_t *)&QTMovieRateDidChangeNotification_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTMovieRateDidChangeNotification\n");
#endif
goto err; 
}
  if (!module_resolve(module_QTKit, SYMBOL_PREFIX "QTMakeTime", (handler_t *)&QTMakeTime_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTMakeTime\n");
#endif
goto err; 
}
  if (!module_resolve(module_QTKit, SYMBOL_PREFIX "QTMovieFileNameAttribute", (handler_t *)&QTMovieFileNameAttribute_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTMovieFileNameAttribute\n");
#endif
goto err; 
}
  if (!module_resolve(module_QTKit, SYMBOL_PREFIX "QTMovieLoopsAttribute", (handler_t *)&QTMovieLoopsAttribute_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTMovieLoopsAttribute\n");
#endif
goto err; 
}
  if (!module_resolve(module_QTKit, SYMBOL_PREFIX "QTMovieNaturalSizeAttribute", (handler_t *)&QTMovieNaturalSizeAttribute_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTMovieNaturalSizeAttribute\n");
#endif
goto err; 
}
  if (!module_resolve(module_QTKit, SYMBOL_PREFIX "QTMovieOpenAsyncOKAttribute", (handler_t *)&QTMovieOpenAsyncOKAttribute_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTMovieOpenAsyncOKAttribute\n");
#endif
goto err; 
}
  if (!module_resolve(module_QTKit, SYMBOL_PREFIX "QTMovieOpenAsyncRequiredAttribute", (handler_t *)&QTMovieOpenAsyncRequiredAttribute_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTMovieOpenAsyncRequiredAttribute\n");
#endif
goto err; 
}
  if (!module_resolve(module_QTKit, SYMBOL_PREFIX "QTMoviePlaysSelectionOnlyAttribute", (handler_t *)&QTMoviePlaysSelectionOnlyAttribute_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTMoviePlaysSelectionOnlyAttribute\n");
#endif
goto err; 
}
  if (!module_resolve(module_QTKit, SYMBOL_PREFIX "QTMovieURLAttribute", (handler_t *)&QTMovieURLAttribute_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTMovieURLAttribute\n");
#endif
goto err; 
}
  if (!module_resolve(module_QTKit, SYMBOL_PREFIX "QTTimeCompare", (handler_t *)&QTTimeCompare_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTTimeCompare\n");
#endif
goto err; 
}
  if (!module_resolve(module_QTKit, SYMBOL_PREFIX "QTMovieLoadStateAttribute", (handler_t *)&QTMovieLoadStateAttribute_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: QTMovieLoadStateAttribute\n");
#endif
goto err; 
}

  return 1;

err:
  if (module_QTKit != NULL)
    module_unload(module_QTKit);

  return 0;
}

int initialise_weak_link_QTKit(void)
{
#if defined(_LINUX)
  if(!initialise_weak_link_QTKit_with_path("none"))
#else
  if (!initialise_weak_link_QTKit_with_path(MODULE_QTKIT_NAME))
#endif
{
#ifdef _DEBUG
    MCLog( "Warning: could not load library: none\n");
#endif
return 0;
}
return -1;
}

#if defined(_LINUX)
void initialise_required_weak_link_QTKit(void)
{
  if (!initialise_weak_link_QTKit())
  {
    failed_required_link("QTKit", "none");
  }
}
#endif

typedef void *(*GetGWorldPixMap_t)(void *pArg0);
GetGWorldPixMap_t GetGWorldPixMap_ptr = NULL;
typedef void (*DisposeGWorld_t)(void *pArg0);
DisposeGWorld_t DisposeGWorld_ptr = NULL;
typedef void *(*GetPixBaseAddr_t)(void *pArg0);
GetPixBaseAddr_t GetPixBaseAddr_ptr = NULL;
typedef void (*LockPixels_t)(void *pArg0);
LockPixels_t LockPixels_ptr = NULL;
typedef void (*UnlockPixels_t)(void *pArg0);
UnlockPixels_t UnlockPixels_ptr = NULL;

#if defined(_MACOSX) || defined(TARGET_SUBPLATFORM_IPHONE)
#define MODULE_QUICKDRAW_NAME "/System/Library/Frameworks/ApplicationServices.framework/Frameworks/QD.framework/QD"
#elif defined(_LINUX) || defined(__EMSCRIPTEN__)
#define MODULE_QUICKDRAW_NAME "none"
#elif defined(TARGET_SUBPLATFORM_ANDROID)
#define MODULE_QUICKDRAW_NAME "none"
#elif defined(_WINDOWS)
#define MODULE_QUICKDRAW_NAME ""
#endif

static module_t module_QuickDraw = NULL;

void finalise_weak_link_QuickDraw(void)
{
  module_unload(module_QuickDraw);
  module_QuickDraw = NULL;
}

int initialise_weak_link_QuickDraw_with_path(const char *p_path)
{
  module_QuickDraw = NULL;
  if (!module_load(p_path, &module_QuickDraw))
  {
  #ifdef _DEBUG
    MCLog( "Unable to load library: %s\n", p_path);
  #endif
    goto err;
  }
  if (!module_resolve(module_QuickDraw, SYMBOL_PREFIX "GetGWorldPixMap", (handler_t *)&GetGWorldPixMap_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: GetGWorldPixMap\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickDraw, SYMBOL_PREFIX "DisposeGWorld", (handler_t *)&DisposeGWorld_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: DisposeGWorld\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickDraw, SYMBOL_PREFIX "GetPixBaseAddr", (handler_t *)&GetPixBaseAddr_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: GetPixBaseAddr\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickDraw, SYMBOL_PREFIX "LockPixels", (handler_t *)&LockPixels_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: LockPixels\n");
#endif
goto err; 
}
  if (!module_resolve(module_QuickDraw, SYMBOL_PREFIX "UnlockPixels", (handler_t *)&UnlockPixels_ptr))
{
#ifdef _DEBUG
MCLog( "Unable to load: UnlockPixels\n");
#endif
goto err; 
}

  return 1;

err:
  if (module_QuickDraw != NULL)
    module_unload(module_QuickDraw);

  return 0;
}

int initialise_weak_link_QuickDraw(void)
{
#if defined(_LINUX)
  if(!initialise_weak_link_QuickDraw_with_path("none"))
#else
  if (!initialise_weak_link_QuickDraw_with_path(MODULE_QUICKDRAW_NAME))
#endif
{
#ifdef _DEBUG
    MCLog( "Warning: could not load library: none\n");
#endif
return 0;
}
return -1;
}

#if defined(_LINUX)
void initialise_required_weak_link_QuickDraw(void)
{
  if (!initialise_weak_link_QuickDraw())
  {
    failed_required_link("QuickDraw", "none");
  }
}
#endif

void *GetGWorldPixMap(void *pArg0)
{
  return GetGWorldPixMap_ptr(pArg0);
}

void DisposeGWorld(void *pArg0)
{
  DisposeGWorld_ptr(pArg0);
}

void *GetPixBaseAddr(void *pArg0)
{
  return GetPixBaseAddr_ptr(pArg0);
}

void LockPixels(void *pArg0)
{
  LockPixels_ptr(pArg0);
}

void UnlockPixels(void *pArg0)
{
  UnlockPixels_ptr(pArg0);
}

}
