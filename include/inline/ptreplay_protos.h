#ifndef _VBCCINLINE_PTREPLAY_H
#define _VBCCINLINE_PTREPLAY_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

struct Module * __PTLoadModule(__reg("a6") void *, __reg("a0") STRPTR name)="\tjsr\t-30(a6)";
#define PTLoadModule(name) __PTLoadModule(PTReplayBase, (name))

VOID __PTUnloadModule(__reg("a6") void *, __reg("a0") struct Module * module)="\tjsr\t-36(a6)";
#define PTUnloadModule(module) __PTUnloadModule(PTReplayBase, (module))

ULONG __PTPlay(__reg("a6") void *, __reg("a0") struct Module * module)="\tjsr\t-42(a6)";
#define PTPlay(module) __PTPlay(PTReplayBase, (module))

ULONG __PTStop(__reg("a6") void *, __reg("a0") struct Module * module)="\tjsr\t-48(a6)";
#define PTStop(module) __PTStop(PTReplayBase, (module))

ULONG __PTPause(__reg("a6") void *, __reg("a0") struct Module * module)="\tjsr\t-54(a6)";
#define PTPause(module) __PTPause(PTReplayBase, (module))

ULONG __PTResume(__reg("a6") void *, __reg("a0") struct Module * module)="\tjsr\t-60(a6)";
#define PTResume(module) __PTResume(PTReplayBase, (module))

VOID __PTFade(__reg("a6") void *, __reg("a0") struct Module * module, __reg("d0") UBYTE speed)="\tjsr\t-66(a6)";
#define PTFade(module, speed) __PTFade(PTReplayBase, (module), (speed))

VOID __PTSetVolume(__reg("a6") void *, __reg("a0") struct Module * module, __reg("d0") UBYTE vol)="\tjsr\t-72(a6)";
#define PTSetVolume(module, vol) __PTSetVolume(PTReplayBase, (module), (vol))

UBYTE __PTSongPos(__reg("a6") void *, __reg("a0") struct Module * module)="\tjsr\t-78(a6)";
#define PTSongPos(module) __PTSongPos(PTReplayBase, (module))

UBYTE __PTSongLen(__reg("a6") void *, __reg("a0") struct Module * module)="\tjsr\t-84(a6)";
#define PTSongLen(module) __PTSongLen(PTReplayBase, (module))

UBYTE __PTSongPattern(__reg("a6") void *, __reg("a0") struct Module * module, __reg("d0") UWORD Pos)="\tjsr\t-90(a6)";
#define PTSongPattern(module, Pos) __PTSongPattern(PTReplayBase, (module), (Pos))

UBYTE __PTPatternPos(__reg("a6") void *, __reg("a0") struct Module * Module)="\tjsr\t-96(a6)";
#define PTPatternPos(Module) __PTPatternPos(PTReplayBase, (Module))

APTR __PTPatternData(__reg("a6") void *, __reg("a0") struct Module * Module, __reg("d0") UBYTE Pattern, __reg("d1") UBYTE Row)="\tjsr\t-102(a6)";
#define PTPatternData(Module, Pattern, Row) __PTPatternData(PTReplayBase, (Module), (Pattern), (Row))

void __PTInstallBits(__reg("a6") void *, __reg("a0") struct Module * Module, __reg("d0") BYTE Restart, __reg("d1") BYTE NextPattern, __reg("d2") BYTE NextRow, __reg("d3") BYTE Fade)="\tjsr\t-108(a6)";
#define PTInstallBits(Module, Restart, NextPattern, NextRow, Fade) __PTInstallBits(PTReplayBase, (Module), (Restart), (NextPattern), (NextRow), (Fade))

struct Module * __PTSetupMod(__reg("a6") void *, __reg("a0") APTR ModuleFile)="\tjsr\t-114(a6)";
#define PTSetupMod(ModuleFile) __PTSetupMod(PTReplayBase, (ModuleFile))

void __PTFreeMod(__reg("a6") void *, __reg("a0") struct Module * Module)="\tjsr\t-120(a6)";
#define PTFreeMod(Module) __PTFreeMod(PTReplayBase, (Module))

void __PTStartFade(__reg("a6") void *, __reg("a0") struct Module * Module, __reg("d0") UBYTE speed)="\tjsr\t-126(a6)";
#define PTStartFade(Module, speed) __PTStartFade(PTReplayBase, (Module), (speed))

void __PTOnChannel(__reg("a6") void *, __reg("a0") struct Module * Module, __reg("d0") BYTE Channels)="\tjsr\t-132(a6)";
#define PTOnChannel(Module, Channels) __PTOnChannel(PTReplayBase, (Module), (Channels))

void __PTOffChannel(__reg("a6") void *, __reg("a0") struct Module * Module, __reg("d0") BYTE Channels)="\tjsr\t-138(a6)";
#define PTOffChannel(Module, Channels) __PTOffChannel(PTReplayBase, (Module), (Channels))

void __PTSetPos(__reg("a6") void *, __reg("a0") struct Module * Module, __reg("d0") UBYTE Pos)="\tjsr\t-144(a6)";
#define PTSetPos(Module, Pos) __PTSetPos(PTReplayBase, (Module), (Pos))

void __PTSetPri(__reg("a6") void *, __reg("d0") BYTE Pri)="\tjsr\t-150(a6)";
#define PTSetPri(Pri) __PTSetPri(PTReplayBase, (Pri))

BYTE __PTGetPri(__reg("a6") void *)="\tjsr\t-156(a6)";
#define PTGetPri() __PTGetPri(PTReplayBase)

BYTE __PTGetChan(__reg("a6") void *)="\tjsr\t-162(a6)";
#define PTGetChan() __PTGetChan(PTReplayBase)

struct PTSample * __PTGetSample(__reg("a6") void *, __reg("a0") struct Module * Module, __reg("d0") WORD Nr)="\tjsr\t-168(a6)";
#define PTGetSample(Module, Nr) __PTGetSample(PTReplayBase, (Module), (Nr))

#endif /*  _VBCCINLINE_PTREPLAY_H  */
