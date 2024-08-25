#include <proto/exec.h>
#include <proto/graphics.h>
#include <graphics/gfxbase.h>
#include <hardware/custom.h>
#include <hardware/dmabits.h>
#include <hardware/intbits.h>

// Vertical blank (hardware) interrupt
void SetInterruptHandler(APTR interrupt) {
	*(volatile APTR*) 0x6c = interrupt;
}

APTR GetInterruptHandler() {
	return *((volatile APTR*) 0x6c);
}

// Declarations
void __interrupt interruptHandler();

UWORD SystemInts;           // backup of initial interrupts
APTR SystemIrq;             // backup of interrupts register
volatile UBYTE *ciaa = (volatile UBYTE *) 0xbfe001;
UBYTE *bitplan1;            // pointer to bitplan data
UWORD SystemDMA;            // backup of initial DMA
UWORD __chip clist[];       // Copperlist

extern void mt_init();
extern void mt_music();
extern void mt_end();
extern struct Custom custom;
extern struct GfxBase *GfxBase;
struct copinit *oldcop;     // Initial copperlist

// Utility functions
void waitLMB() {
    while ((*ciaa & 64) != 0);
}

int startup() {
    // Allocating memory (chipram) for bitplans
    if ((bitplan1 = AllocMem(0x2800, MEMF_CHIP|MEMF_CLEAR)) == NULL) return 1;
    // Updating copperlist with bitplan address
    clist[1] = (UWORD)((ULONG)bitplan1>>16);       // BPL1PTH
    clist[3] = (UWORD)(ULONG)bitplan1;             // BPL1PTL

    // Saving initial copperlist
    GfxBase = (struct GfxBase*)OpenLibrary("graphics.library", 0);
    oldcop = GfxBase->copinit;

    SystemDMA = custom.dmaconr|DMAF_SETCLR;      // Saving initial DMA with the SET/CLR flag set

    SystemInts = custom.intenar|INTF_SETCLR;     // Saving initial interrupts with the SET/CLR flag set
    SystemIrq = GetInterruptHandler();           // Saving initial interrupt vector

    WaitTOF();                                                                          // Waiting for both copperlists to finish
    WaitTOF();

    custom.intreq = 0x7FFF;                                                             // Clear all interrupts
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
    
    SetInterruptHandler((APTR)interruptHandler);                                        // Setting new interrupt handler
    custom.intena = INTF_SETCLR | INTF_INTEN | INTF_VERTB;
    
    custom.copjmp1 = 0x0000;   
    
    mt_init();                                                         // copper start
    return 0;
}

void restore() {
    if (bitplan1) FreeMem(bitplan1, 0x2800);    // Frees reserved memory
    custom.dmacon = SystemDMA;                  // Restores initial DMA
    custom.cop1lc = (ULONG)oldcop;              // Restores initial copperlist
    CloseLibrary((struct Library *)GfxBase);
    SetInterruptHandler(SystemIrq);             // Restores interrupts
    custom.intena = SystemInts;
}

/****************************************************************
* Here you can place code to run during vertical blank interval *
****************************************************************/

__interrupt void interruptHandler() {
    mt_music();
    custom.intreq=INTF_VERTB; custom.intreq=INTF_VERTB; //reset vbl req. twice for a4000 bug.
}

/*************************
 * Here starts your code *
 * **********************/

// Basic copperlist : just resets bitplan pointers and color registers at each frame
UWORD __chip clist[] = {
    0x00E0, 0x0000,
    0x00E2, 0x0000,
    0x0180, 0x0000,
    0x0182, 0x0FFF,
    0xFFFF, 0xFFFE
};

int main() {
    if (startup()) return 10;

    waitLMB();
    mt_end();
    restore();

    return 0;
}