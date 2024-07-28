#include <proto/exec.h>
#include <proto/graphics.h>
#include <graphics/gfxbase.h>
#include <hardware/custom.h>
#include <hardware/dmabits.h>

/********************************************
 * Here you can activate various features:  *
 *                                          *
 * MODPLAY for protracker modules replay    *
 * via ptreplay.library                     *
 *                                          *
 * VBL_HW_INT for hardware VBL interrupts   *
 * Warning that will not work with MODPLAY  *
 * 
 * VBL_SYS_INT for system friendly VBL      *
 * interrupts - compatible with MODPLAY     *
 * *****************************************/
 
#define MODPLAY
#define VBL_HW_INT
#define MODULE "assets/red.mod"

// Vertical blank (hardware) interrupt
#ifdef VBL_HW_INT
#include <hardware/intbits.h>
void SetInterruptHandler(APTR interrupt) {
	*(volatile APTR*) 0x6c = interrupt;
}

APTR GetInterruptHandler() {
	return *((volatile APTR*) 0x6c);
}

void __interrupt interruptHandler();

UWORD SystemInts;           // backup of initial interrupts
APTR SystemIrq;             // backup of interrupts register
#endif

// Variables declarations
volatile UBYTE *ciaa = (volatile UBYTE *) 0xbfe001;
UBYTE *bitplan1;            // pointer to bitplan data
UWORD SystemDMA;            // backup of initial DMA
UWORD __chip clist[];       // Copperlist

extern void mt_music();
extern struct Custom custom;
extern struct GfxBase *GfxBase;
struct copinit *oldcop;     // Initial copperlist

// Functions declarations
void waitLMB() {
    while ((*ciaa & 64) != 0);
}

int startup() {
    // Allocating memory (chipram) for bitplans
    if ((bitplan1 = AllocMem(0x2800, MEMF_CHIP|MEMF_CLEAR)) == NULL) return 1;
    // Updating copperlist with bitplan address
    ULONG bpl1addr;
    bpl1addr = (ULONG)bitplan1;
    clist[1] = (UWORD)(bpl1addr>>16);       // BPL1PTH
    clist[3] = (UWORD)bpl1addr;             // BPL1PTL

    // Saving initial copperlist
    GfxBase = (struct GfxBase*)OpenLibrary("graphics.library", 0);
    oldcop = GfxBase->copinit;

    SystemDMA = custom.dmaconr|0x8000;      // Saving initial DMA with the SET/CLR flag set

    #ifdef VBL_HW_INT
    SystemInts = custom.intenar|0x8000;     // Saving initial interrupts
    SystemIrq = GetInterruptHandler();      // Store interrupt register
    #endif

    WaitTOF();                                                                          // Waiting for both copperlists to finish
    WaitTOF();

    custom.dmacon = 0x7FFF;                                                             // Clear all DMA channels
    custom.intreq = 0x7FFF;                                                             // Clear all interrupts
    custom.bplcon0 = 0x1000;                                                            // 1 bitplan in low resolution
    custom.bplcon1 = 0x0000;
    custom.ddfstrt = 0X0038;
    custom.ddfstop = 0X00D0;
    custom.diwstrt = 0x2C81;
    custom.diwstop = 0x2CC1;
    custom.bpl1mod = 0x0000;
    custom.cop1lc = (ULONG)clist;                                                       // copperlist address
    custom.dmacon = DMAF_SETCLR | DMAF_MASTER | DMAF_COPPER | DMAF_RASTER;              // playfield and copper DMA enabled
    #ifdef VBL_HW_INT
    SetInterruptHandler((APTR)interruptHandler);                                        // Setting new interrupt handler
    custom.intena = INTF_SETCLR | INTF_INTEN | INTF_VERTB;
    #endif
    custom.copjmp1 = 0x0000;                                                            // copper start
    return 0;
}

void restore() {
    if (bitplan1) FreeMem(bitplan1, 0x2800);    // Frees reserved memory
    custom.dmacon = SystemDMA;                  // Restores initial DMA
    custom.cop1lc = (ULONG)oldcop;              // Restores initial copperlist
    CloseLibrary((struct Library *)GfxBase);
    #ifdef VBL_HW_INT
    SetInterruptHandler(SystemIrq);             // Restores interrupts
    custom.intena = SystemInts;
    #endif
    #ifdef VBL_SYS_INT
    RemIntServer(INTB_VERTB, vbint);
    FreeMem(vbint, sizeof(struct Interrupt));
    #endif
}

#ifdef MODPLAY
#endif

/****************************************************************
* Here you can place code to run during vertical blank interval *
****************************************************************/

#ifdef VBL_HW_INT
__interrupt void interruptHandler() {
    mt_music()
    custom.intreq=INTF_VERTB; custom.intreq=INTF_VERTB; //reset vbl req. twice for a4000 bug.
}
#endif

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
    #ifdef MODPLAY
    //mod_play();
    #endif
    waitLMB();
    #ifdef MODPLAY
    //mod_stop();
    #endif
    restore();
    return 0;
}