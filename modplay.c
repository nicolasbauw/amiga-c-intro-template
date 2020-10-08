#include <proto/exec.h>
#include "include/ptreplay.h"

#define MODULE "assets/red.mod"

struct Library *PTReplayBase;
struct Module *Mod = NULL;
BYTE SigBit;

int mod_play() {
	if((PTReplayBase = OpenLibrary("ptreplay.library",0L)) && (SigBit=AllocSignal(-1)!=-1)) {
		if(Mod = PTLoadModule(MODULE)) {
			PTInstallBits(Mod, SigBit, -1, -1, -1);
			PTPlay(Mod);
			return 0;
		}
	return 1;
	}
}

void mod_stop() {
	PTStop(Mod);
	FreeSignal(SigBit);
	PTUnloadModule(Mod);
	CloseLibrary(PTReplayBase);
}
