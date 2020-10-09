#include <proto/exec.h>
#include <proto/graphics.h>
#include <graphics/gfxbase.h>
#include <hardware/custom.h>
#include <hardware/dmabits.h>

#define MODPLAY
#define DEBUG
#define VBLINT

#ifdef DEBUG            // Makefile :  For debug : aos68k. If no debug : aos68km
#include <stdio.h>
ULONG counter = 0;
#endif

// Protracker module replay
#ifdef MODPLAY
int mod_play();
int mod_stop();
#endif

// Vertical blank interrupt
#ifdef VBLINT
#include <hardware/intbits.h>
void SetInterruptHandler(APTR interrupt) {
	*(volatile APTR*) 0x6c = interrupt;
}

APTR GetInterruptHandler() {
	return *((volatile APTR*) 0x6c);
}

void __amigainterrupt interruptHandler();

UWORD SystemInts;           // backup of initial interrupts
APTR SystemIrq;             // backup of interrupts register
#endif


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

    SystemDMA = custom.dmaconr|0x8000;    // Saving initial DMA with the SET/CLR flag set
    #ifdef VBLINT
    SystemInts = custom.intenar|0x8000;
    SystemIrq = GetInterruptHandler();                                                    // Store interrupt register
    #endif

    WaitTOF();                          // Waiting for both copperlists to finish
    WaitTOF();

    #ifdef DEBUG
    printf("copperlist address : %8x\n", (ULONG)clist);
    #endif

    custom.dmaconr = 0x7FFF;                                                            // Clear all DMA channels
    custom.intreqr = 0x7fff;                                                            // Clear all interrupts
	custom.bplcon0 = 0x1000;                                                            // 1 bitplan in low resolution
	custom.bplcon1 = 0x0000;
	custom.ddfstrt = 0X0038;
	custom.ddfstop = 0X00D0;
	custom.diwstrt = 0x2C81;
	custom.diwstop = 0x2CC1;
	custom.bpl1mod = 0x0000;
	custom.cop1lc = (ULONG)clist;                                                       // copperlist address
	custom.dmacon = DMAF_SETCLR | DMAF_MASTER | DMAF_COPPER | DMAF_RASTER;              // playfield and copper DMA enabled
    #ifdef VBLINT
    //SetInterruptHandler((APTR)interruptHandler);                                        // Setting new interrupt handler
    custom.intena = INTF_SETCLR | INTF_INTEN | INTF_VERTB;
    #endif
    custom.copjmp1 = 0x0000;                                                            // copper start
}

void restore() { 
	if (bitplan1) FreeMem(bitplan1, 0x2800);    // Frees reserved memory
    custom.dmacon = SystemDMA;                  // Restores initial DMA
    custom.cop1lc = (ULONG)oldcop;              // Restores initial copperlist
    CloseLibrary((struct Library *)GfxBase);
    #ifdef VBLINT
    SetInterruptHandler(SystemIrq);             // Restores interrupts
    custom.intena = SystemInts;
    #endif
    #ifdef DEBUG
    printf("%d\n", counter);
    #endif
}

#ifdef VBLINT
void __amigainterrupt interruptHandler() {
	custom.intreq=(UWORD)0x4020; custom.intreq=(UWORD)0x4020; //reset vbl req. twice for a4000 bug.
    #ifdef DEBUG
    counter ++;
    ULONG i = 0;
    while (i<0x000FFFFF) {i++;};
    #endif
}
#endif

int main() {
    // Allocating memory (chipram) for bitplans
    if ((bitplan1 = AllocMem(0x2800, MEMF_CHIP|MEMF_CLEAR)) == NULL) return 1;
    startup();
    #ifdef MODPLAY
    mod_play();
    #endif
    waitLMB();
    #ifdef MODPLAY
    mod_stop();
    #endif
    restore();
    return 0;
}