#include <proto/exec.h>
#include <proto/graphics.h>
#include <graphics/gfxbase.h>
#include <hardware/custom.h>
#include <hardware/dmabits.h>

//#define DEBUG
#ifdef DEBUG
#include <stdio.h>
#endif

int mod_play();
int mod_stop();

volatile UBYTE *ciaa = (volatile UBYTE *) 0xbfe001;
UBYTE *bitplan1;            // pointer to bitplan data
UWORD SystemDMA;            // backup of initial DMA

extern struct Custom custom;
extern struct GfxBase *GfxBase;
struct copinit *oldcop;

// Basic copperlist : just resets bitplan pointers at each frame
UWORD __chip clist[] = {
    0x00E0, 0x0000,
    0x00E2, 0x0000,
    0x0180, 0x0000,
    0x0182, 0x0FFF,
    0xFFFF, 0xFFFE
};

void waitLMB() {
    while ((*ciaa & 64) != 0);
}

void startup() {
    // Updating copperlist with bitplan address
    ULONG bpl1addr;
    bpl1addr = (ULONG)bitplan1;
    clist[1] = (UWORD)(bpl1addr>>16);       // BPL1PTH
    clist[3] = (UWORD)bpl1addr;             // BPL1PTL

    #ifdef DEBUG
    printf("Bitplan address : %8x\n", bpl1addr);
    printf("BPL1PTH - BPL1PTL : %04x %04x\n", clist[1], clist[3]);
    #endif

    // Saving initial copperlist
	GfxBase = (struct GfxBase*)OpenLibrary("graphics.library", 0);
	oldcop = GfxBase->copinit;

    SystemDMA=custom.dmaconr|0x8000;    // Saving initial DMA with the SET/CLR flag set
    WaitTOF();                          // Waiting for both copperlists to finish
    WaitTOF();

    #ifdef DEBUG
    printf("copperlist address : %8x\n", (ULONG)clist);
    #endif

    custom.dmacon = 0x7FFF;                                                             // Clear all DMA channels
	custom.bplcon0 = 0x1000;                                                            // 1 bitplan in low resolution
	custom.bplcon1 = 0x0000;
	custom.ddfstrt = 0X0038;
	custom.ddfstop = 0X00D0;
	custom.diwstrt = 0x2C81;
	custom.diwstop = 0x2CC1;
	custom.bpl1mod = 0x0000;
	custom.cop1lc = (ULONG)clist;                                                       // copperlist address
	custom.dmacon = DMAF_SETCLR | DMAF_MASTER | DMAF_COPPER | DMAF_RASTER;              // playfield and copper DMA enabled
    custom.copjmp1 = 0x0000;                                                            // copper start
}

void restore() { 
	if (bitplan1) FreeMem(bitplan1, 0x2800);    // Frees reserved memory
    custom.dmacon = SystemDMA;                  // Restores initial DMA
    custom.cop1lc = (ULONG)oldcop;              // Restores initial copperlist
    CloseLibrary((struct Library *)GfxBase);
}

int main() {
    // Allocating memory (chipram) for bitplans
    if ((bitplan1 = AllocMem(0x2800, MEMF_CHIP|MEMF_CLEAR)) == NULL) return 1;
    startup();
    mod_play();
    waitLMB();
    mod_stop();
    restore();
    return 0;
}