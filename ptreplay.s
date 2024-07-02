


;*--------------T-----------T-------------------------------T------------T-----
;* Protracker V3.0a ReplayCode (68000)
;* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;*
;* Based on the V2.xx code from Mushroom Studios.
;*
;* Date: 22.06.97
;*
;* This is a high optimized replay code for Pro/NoiseTracker modules.
;* It's not for learning .. it's for playing ;)
;* - 100% PC-Relativ.
;* - High Speed Replay.
;* - Less Bytes
;* - Linkable.
;* - Fixed bad period handling.
;* But there still tempo problems!
;* -Use the CED-Tabs in the 4th line
;*
;* lea your module (mt_data) to a0 and call mt_init.
;* No registers will be crashed.
;* Tested with Devpac, SNMA, PhxAss, Barfly, OMA, AsmOne, MaxonAsm
;*-----------------------------------------------------------------------------

INIT_SPEED	EQU	6
TEMPO_MIN	EQU	3 ;(blt)	;set here the tempo
TEMPO_MAX	EQU	8 ;(bgt)	;min/max rates
NO_TEMPO	SET	0	;set this to 1
			;and tempo e-commands
			;will be ignored
NO_MINMAX	SET	1	;set this to 1
			;and min/max tempo will
			;be ignored
	XDEF	mt_init
	XDEF	mt_music
	XDEF	mt_end

n_note	EQU	0  ;w
n_cmd	EQU	2  ;w
n_cmdlo	EQU	3  ;b
n_start	EQU	4  ;l
n_length	EQU	8  ;w
n_loopstart	EQU	10 ;l
n_replen	EQU	14 ;w
n_period	EQU	16 ;w
n_finetune	EQU	18 ;b
n_volume	EQU	19 ;b
n_dmabit	EQU	20 ;w
n_toneportdirec	EQU	22 ;b
n_toneportspeed	EQU	23 ;b
n_wantedperiod	EQU	24 ;w
n_vibratocmd	EQU	26 ;b
n_vibratopos	EQU	27 ;b
n_tremolocmd	EQU	28 ;b
n_tremolopos	EQU	29 ;b
n_wavecontrol	EQU	30 ;b
n_glissfunk	EQU	31 ;b
n_sampleoffset	EQU	32 ;b
n_pattpos	EQU	33 ;b
n_loopcount	EQU	34 ;b
n_funkoffset	EQU	35 ;b
n_wavestart	EQU	36 ;l
n_reallength	EQU	40 ;w
n_trigger	=	42	; b

;*-----------------------------------------------------------------------------


mt_init	movem.l	d0-d2/a0-a3,-(sp)
	lea	mt_base(pc),a3
	move.l	a0,mt_songdata-mt_base(a3)
	lea	952(a0),a1
	moveq	#128-1,d0
	moveq	#0,d1
	moveq	#0,d2
mt_ghighpp	move.b	(a1)+,d1
	cmp.b	d2,d1
	ble.s	mt_ples
	move.b	d1,d2
mt_ples	dbra	d0,mt_ghighpp
	addq.b	#1,d2
	lea	mt_samples-mt_base(a3),a1
	lsl.l	#8,d2
	add.l	d2,d2
	add.l	d2,d2
	lea	(a0,d2.l),a2
	lea	1084(a2),a2
	moveq	#31-1,d0
mt_stufsmp

;	clr.l	(a2)			; OUT OF RANGE SOMETIMES!!!


	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	add.l	d1,d1
	add.l	d1,a2
	lea	30(a0),a0
	dbra	d0,mt_stufsmp
	or.b	#2,$BFE001
	moveq	#INIT_SPEED,d0
	move.b	d0,mt_speed-mt_base(a3)
	clr.b	mt_counter-mt_base(a3)
	clr.b	mt_songpos-mt_base(a3)
	clr.w	mt_pattpos-mt_base(a3)
	movem.l	(sp)+,d0-d2/a0-a3
mt_end	move.l	a0,-(sp)
	lea	$DFF000,a0
	clr.w	$A8(a0)
	clr.w	$B8(a0)
	clr.w	$C8(a0)
	clr.w	$D8(a0)
	move.w	#15,$96(a0)
	move.l	(sp)+,a0
	rts


;*-----------------------------------------------------------------------------


mt_music	movem.l	d0-d7/a0-a6,-(sp)
	moveq	#$0F,d7
	move.b	#$F0,d5
	lea	mt_base(pc),a4
	lea	$DFF0A0,a5
	lea	mt_counter-mt_base(a4),a0
	addq.b	#1,(a0)
	move.b	(a0),d0
	cmp.b	mt_speed-mt_base(a4),d0
	blt.s	mt_nonewnote
	clr.b	(a0)
	tst.b	mt_patdeltime2-mt_base(a4)
	beq.s	mt_getnewnote
	pea	mt_dmaskip-mt_base(a4)
	bra.s	mt_nonewvoice


mt_nonewnote	pea	mt_nonewpos-mt_base(a4)
mt_nonewvoice	lea	mt_voice1-mt_base(a4),a6
	bsr	mt_checkefx
	lea	$10(a5),a5
	lea	mt_voice2-mt_base(a4),a6
	bsr	mt_checkefx
	lea	$10(a5),a5
	lea	mt_voice3-mt_base(a4),a6
	bsr	mt_checkefx
	lea	$10(a5),a5
	lea	mt_voice4-mt_base(a4),a6
	bra	mt_checkefx


mt_getnewnote	move.l	mt_songdata-mt_base(a4),a0
	lea	12(a0),a3
	lea	952(a0),a2
	lea	1084(a0),a0
	moveq	#0,d0
	moveq	#0,d1
	move.b	mt_songpos-mt_base(a4),d0
	move.b	(a2,d0.w),d1
	lsl.l	#8,d1
	add.l	d1,d1
	add.l	d1,d1
	add.w	mt_pattpos-mt_base(a4),d1
	clr.w	mt_dmacon-mt_base(a4)
	lea	mt_voice1-mt_base(a4),a6
	bsr.s	mt_playvoice
	lea	$10(a5),a5
	lea	mt_voice2-mt_base(a4),a6
	bsr.s	mt_playvoice
	lea	$10(a5),a5
	lea	mt_voice3-mt_base(a4),a6
	bsr.s	mt_playvoice
	lea	$10(a5),a5
	lea	mt_voice4-mt_base(a4),a6
	pea	mt_setdma-mt_base(a4)


mt_playvoice	tst.l	(a6)
	bne.s	mt_plvskip
	bsr	mt_periodnop
mt_plvskip	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	n_cmd(a6),d2
	lsr.b	#4,d2
	move.b	(a6),d0
	and.b	d5,d0
	or.b	d0,d2
	beq	mt_setregs
	moveq	#0,d3
	lea	mt_samples-mt_base(a4),a1
	move.w	d2,d4
	subq.l	#1,d2
	add.l	d2,d2
	add.l	d2,d2
	move.w	d4,d6
	lsl.w	#5,d4
	sub.w	d6,d4
	sub.w	d6,d4
	move.l	(a1,d2.l),n_start(a6)
	move.w	(a3,d4.w),n_length(a6)
	move.w	(a3,d4.w),n_reallength(a6)
	move.b	2(a3,d4.w),n_finetune(a6)
	move.b	3(a3,d4.w),n_volume(a6)
	move.w	4(a3,d4.w),d3
	beq.s	mt_noloop

	move.l	n_start(a6),d2
	move.w	d3,d6
	add.w	d3,d3
	add.l	d3,d2
	move.l	d2,n_loopstart(a6)
	move.l	d2,n_wavestart(a6)
	move.w	6(a3,d4.w),d0
	move.w	d0,n_replen(a6)
	add.w	d6,d0
	move.w	d0,n_length(a6)
	moveq	#0,d0
	move.b	n_volume(a6),d0
	move.w	d0,8(a5)
	bra.s	mt_setregs

mt_noloop	move.l	n_start(a6),d2
	add.l	d3,d2
	move.l	d2,n_loopstart(a6)
	move.l	d2,n_wavestart(a6)
	move.w	6(a3,d4.w),n_replen(a6)
	moveq	#0,d0
	move.b	n_volume(a6),d0
	move.w	d0,8(a5)

mt_setregs	move.w	(a6),d0
	and.w	#$0FFF,d0
	beq	mt_checkefx2
	move.w	n_cmd(a6),d0
	and.w	#$0FF0,d0
	cmp.w	#$0E50,d0
	beq.s	mt_dostfnetu
	move.b	n_cmd(a6),d0
	and.b	d7,d0
	moveq	#3,d6
	cmp.b	d6,d0
	beq.s	mt_chktonepor
	moveq	#5,d6
	cmp.b	d6,d0
	beq.s	mt_chktonepor
	moveq	#9,d6
	cmp.b	d6,d0
	bne.s	mt_setperiod
	pea	mt_setperiod-mt_base(a4)
	bra	mt_checkefx2


mt_chktonepor	pea	mt_checkefx2-mt_base(a4)
	bra	mt_sttonepor


mt_dostfnetu	bsr	mt_stfinetune
mt_setperiod	move.w	(a6),d2
	and.w	#$0FFF,d2
	lea	mt_periodtab-mt_base(a4),a1
	moveq	#0,d0
	moveq	#36-1,d3
mt_ftuloop	cmp.w	(a1,d0.w),d2
	bge.s	mt_ftufound
	addq.l	#2,d0
	dbra	d3,mt_ftuloop
mt_ftufound	moveq	#0,d2
	move.b	n_finetune(a6),d2
	mulu.w	#36*2,d2
	add.l	d2,a1
	move.w	(a1,d0.w),n_period(a6)

	move.w	n_cmd(a6),d0
	and.w	#$0FF0,d0
	cmp.w	#$0ED0,d0
	beq	mt_checkefx2

	move.w	n_dmabit(a6),$DFF096
	btst	#2,n_wavecontrol(a6)
	bne.s	mt_vibnoc
	clr.b	n_vibratopos(a6)
mt_vibnoc	btst	#6,n_wavecontrol(a6)
	bne.s	mt_trenoc
	clr.b	n_tremolopos(a6)
mt_trenoc	move.l	n_start(a6),(a5)
	move.w	n_length(a6),4(a5)
	move.w	n_period(a6),6(a5)
	st	n_trigger(a6)
	move.w	n_dmabit(a6),d0
	or.w	d0,mt_dmacon-mt_base(a4)
	bra	mt_checkefx2


mt_dmawait	moveq	#5-1,d0
mt_loop3	move.b	$DFF006,d6
mt_loop4	cmp.b	$DFF006,d6
	beq.s	mt_loop4
	dbra	d0,mt_loop3
	rts


mt_setdma	bsr.s	mt_dmawait
	lea	$DFF000,a5
	move.w	mt_dmacon-mt_base(a4),d0
	or.w	#$8000,d0
	move.w	d0,$96(a5)
	bsr.s	mt_dmawait

	lea	mt_voice4-mt_base(a4),a6
	move.l	n_loopstart(a6),$D0(a5)
	move.w	n_replen(a6),$D4(a5)
	lea	mt_voice3-mt_base(a4),a6
	move.l	n_loopstart(a6),$C0(a5)
	move.w	n_replen(a6),$C4(a5)
	lea	mt_voice2-mt_base(a4),a6
	move.l	n_loopstart(a6),$B0(a5)
	move.w	n_replen(a6),$B4(a5)
	lea	mt_voice1-mt_base(a4),a6
	move.l	n_loopstart(a6),$A0(a5)
	move.w	n_replen(a6),$A4(a5)
mt_dmaskip	add.w	#16,mt_pattpos-mt_base(a4)
	move.b	mt_patdeltime-mt_base(a4),d0
	beq.s	mt_dskc
	move.b	d0,mt_patdeltime2-mt_base(a4)
	clr.b	mt_patdeltime-mt_base(a4)

mt_dskc	tst.b	mt_patdeltime2-mt_base(a4)
	beq.s	mt_dska
	subq.b	#1,mt_patdeltime2-mt_base(a4)
	beq.s	mt_dska
	sub.w	#16,mt_pattpos-mt_base(a4)
mt_dska	tst.b	mt_break-mt_base(a4)
	beq.s	mt_nnpysk
	clr.b	mt_break-mt_base(a4)
	moveq	#0,d0
	move.b	mt_breakpos-mt_base(a4),d0
	clr.b	mt_breakpos-mt_base(a4)
	lsl.w	#4,d0
	move.w	d0,mt_pattpos-mt_base(a4)
mt_nnpysk	cmp.w	#1024,mt_pattpos-mt_base(a4)
	blt.s	mt_nonewpos
mt_nextpos	moveq	#0,d0
	move.b	mt_breakpos-mt_base(a4),d0
	lsl.w	#4,d0
	move.w	d0,mt_pattpos-mt_base(a4)
	clr.b	mt_breakpos-mt_base(a4)
	clr.b	mt_jmpflg-mt_base(a4)
	lea	mt_songpos-mt_base(a4),a1
	addq.b	#1,(a1)
	and.b	#$7f,(a1)
	move.b	(a1),d1
	move.l	mt_songdata-mt_base(a4),a0
	cmp.b	950(a0),d1
	blt.s	mt_nonewpos
	clr.b	(a1)
mt_nonewpos	tst.b	mt_jmpflg-mt_base(a4)
	bne.s	mt_nextpos
	movem.l	(sp)+,d0-d7/a0-a6
	rts


mt_checkefx	bsr	mt_updatefunk
	move.w	n_cmd(a6),d0
	and.w	#$0FFF,d0
	beq.s	mt_periodnop
	lsr.w	#8,d0
	beq.s	mt_arpeggio
	subq.b	#1,d0
	beq	mt_porup
	subq.b	#1,d0
	beq	mt_pordown
	subq.b	#1,d0
	beq	mt_tonepor
	subq.b	#1,d0
	beq	mt_vibrato
	subq.b	#1,d0
	beq	mt_tonevolslide
	subq.b	#1,d0
	beq	mt_vibvolslide
	subq.b	#8,d0
	beq	mt_ecomms
	move.w	n_period(a6),6(a5)
	addq.b	#4,d0
	beq	mt_volumeslide
	addq.b	#3,d0
	beq	mt_tremolo
	rts


mt_periodnop	move.w	n_period(a6),6(a5)
	rts


mt_arpeggio	moveq	#0,d1
	moveq	#0,d0
	move.b	mt_counter-mt_base(a4),d1
	divs.w	#3,d1
	swap	d1
	tst.w	d1
	beq.s	mt_arp2
	move.b	n_cmdlo(a6),d0
	subq.w	#2,d1
	beq.s	mt_arp1
	lsr.b	#4,d0
	bra.s	mt_arp3
mt_arp1	and.b	d7,d0
mt_arp3	add.w	d0,d0
	moveq	#0,d1
	move.b	n_finetune(a6),d1
	mulu.w	#36*2,d1
	lea	mt_periodtab-mt_base(a4),a0
	add.l	d1,a0
	move.w	n_period(a6),d1
	moveq	#36-1,d3
mt_arploop	move.w	(a0,d0.w),d2
	cmp.w	(a0)+,d1
	bge.s	mt_arp4
	dbra	d3,mt_arploop
	rts
mt_arp2	move.w	n_period(a6),6(a5)
	rts
mt_arp4	move.w	d2,6(a5)
	rts


mt_fineporup	tst.b	mt_counter-mt_base(a4)
	bne.s	mt_rts
	move.b	d7,mt_lowmask-mt_base(a4)
mt_porup	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	mt_lowmask-mt_base(a4),d0
	lea	n_period(a6),a1
	sub.w	d0,(a1)
	move.w	(a1),d0
	and.w	#$0FFF,d0
	moveq	#113,d6
	cmp.w	d6,d0
	bpl.s	mt_porupskip
mt_porand	and.w	#$F000,(a1)
	or.w	d6,(a1)
mt_porupskip	move.w	(a1),d0
	and.w	#$0FFF,d0
	move.w	d0,6(a5)
	st	mt_lowmask-mt_base(a4)
mt_rts	rts


mt_finepordown	tst.b	mt_counter-mt_base(a4)
	bne.s	mt_rts
	move.b	d7,mt_lowmask-mt_base(a4)
mt_pordown	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	mt_lowmask-mt_base(a4),d0
	lea	n_period(a6),a1
	add.w	d0,(a1)
	move.w	(a1),d0
	and.w	#$0FFF,d0
	move.w	#856,d6
	cmp.w	d6,d0
	bmi.s	mt_porupskip
	bra.s	mt_porand


mt_sttonepor	move.w	(a6),d2
	and.w	#$0FFF,d2
	moveq	#0,d0
	move.b	n_finetune(a6),d0
	moveq	#36*2,d3
	mulu.w	d3,d0
	lea	mt_periodtab-mt_base(a4),a1
	add.l	d0,a1
	moveq	#0,d0
mt_stploop	cmp.w	(a1,d0.w),d2
	bge.s	mt_stpfound
	addq.w	#2,d0
	cmp.w	d3,d0
	blt.s	mt_stploop
	moveq	#35*2,d0
mt_stpfound	move.b	n_finetune(a6),d2
	and.b	#8,d2
	beq.s	mt_stpgoss
	tst.w	d0
	beq.s	mt_stpgoss
	subq.w	#2,d0
mt_stpgoss	move.w	(a1,d0.w),d2
	move.w	d2,n_wantedperiod(a6)
	cmp.w	n_period(a6),d2
	sle	n_toneportdirec(a6)
	bne.s	mt_nclrtonepor
	clr.w	n_wantedperiod(a6)
mt_nclrtonepor	rts


mt_tonepor	move.b	n_cmdlo(a6),d0
	beq.s	mt_tonepornchg
	move.b	d0,n_toneportspeed(a6)
mt_tonepornchg	lea	n_wantedperiod(a6),a0
	lea	n_period(a6),a1
	tst.w	(a0)
	beq.s	mt_nclrtonepor
	moveq	#0,d0
	move.b	n_toneportspeed(a6),d0
	tst.b	n_toneportdirec(a6)
	bne.s	mt_toneporup
	add.w	d0,(a1)
	move.w	(a0),d0
	cmp.w	(a1),d0
	bgt.s	mt_toneporstper
	move.w	(a0),(a1)
	clr.w	(a0)
	bra.s	mt_toneporstper

mt_toneporup	sub.w	d0,(a1)
	move.w	(a0),d0
	cmp.w	(a1),d0
	blt.s	mt_toneporstper
	move.w	(a0),(a1)
	clr.w	(a0)
mt_toneporstper	move.w	(a1),d2
	move.b	n_glissfunk(a6),d0
	and.b	d7,d0
	beq.s	mt_glissskip
	moveq	#0,d0
	move.b	n_finetune(a6),d0
	moveq	#36*2,d6
	mulu.w	d6,d0
	lea	mt_periodtab-mt_base(a4),a0
	add.l	d0,a0
	moveq	#0,d0
mt_glissloop	cmp.w	(a0,d0.w),d2
	bge.s	mt_glissfound
	addq.w	#2,d0
	cmp.w	d6,d0
	blt.s	mt_glissloop
	moveq	#35*2,d0
mt_glissfound	move.w	(a0,d0.w),d2
mt_glissskip	move.w	d2,6(a5)
	rts


mt_vibrato	move.b	n_cmdlo(a6),d0
	beq.s	mt_vib2
	move.b	n_vibratocmd(a6),d2
	and.b	d7,d0
	beq.s	mt_vibskip
	and.b	d5,d2
	or.b	d0,d2
mt_vibskip	move.b	n_cmdlo(a6),d0
	and.b	d5,d0
	beq.s	mt_vibskip2
	and.b	d7,d2
	or.b	d0,d2
mt_vibskip2	move.b	d2,n_vibratocmd(a6)
mt_vib2	move.b	n_vibratopos(a6),d0
	lea	mt_vibtab-mt_base(a4),a3
	lsr.w	#2,d0
	and.w	#$001F,d0
	moveq	#0,d2
	move.b	n_wavecontrol(a6),d2
	and.b	#3,d2
	beq.s	mt_vibsine
	lsl.b	#3,d0
	subq.b	#1,d2
	beq.s	mt_vibrampdown
	st	d2
	bra.s	mt_vibset
mt_vibrampdown	tst.b	n_vibratopos(a6)
	bpl.s	mt_vibrampdown2
	st	d2
	sub.b	d0,d2
	bra.s	mt_vibset
mt_vibrampdown2	move.b	d0,d2
	bra.s	mt_vibset
mt_vibsine	move.b	(a3,d0.w),d2
mt_vibset	move.b	n_vibratocmd(a6),d0
	and.w	#$000F,d0
	mulu.w	d0,d2
	lsr.w	#7,d2
	move.w	n_period(a6),d0
	tst.b	n_vibratopos(a6)
	bmi.s	mt_vibneg
	add.w	d2,d0
	bra.s	mt_vib3
mt_vibneg	sub.w	d2,d0
mt_vib3	move.w	d0,6(a5)
	move.b	n_vibratocmd(a6),d0
	lsr.w	#2,d0
	and.b	#$3C,d0
	add.b	d0,n_vibratopos(a6)
	rts


mt_tonevolslide	pea	mt_volumeslide-mt_base(a4)
	bra	mt_tonepornchg
mt_vibvolslide	pea	mt_volumeslide-mt_base(a4)
	bra.s	mt_vib2


mt_tremolo	move.b	n_cmdlo(a6),d0
	beq.s	mt_trem2
	move.b	n_tremolocmd(a6),d2
	and.b	d7,d0
	beq.s	mt_tremskip
	and.b	d5,d2
	or.b	d0,d2
mt_tremskip	move.b	n_cmdlo(a6),d0
	and.b	d5,d0
	beq.s	mt_tremskip2
	and.b	d7,d2
	or.b	d0,d2
mt_tremskip2	move.b	d2,n_tremolocmd(a6)
mt_trem2	move.b	n_tremolopos(a6),d0
	lea	mt_vibtab-mt_base(a4),a3
	lsr.w	#2,d0
	and.w	#$001F,d0
	moveq	#0,d2
	move.b	n_wavecontrol(a6),d2
	lsr.b	#4,d2
	and.b	#3,d2
	beq.s	mt_tremsine
	lsl.b	#3,d0
	subq.b	#1,d2
	beq.s	mt_tremrmpdwn
	st	d2
	bra.s	mt_tremset
mt_tremrmpdwn	tst.b	n_vibratopos(a6)
	bpl.s	mt_tremrmpdwn2
	st	d2
	sub.b	d0,d2
	bra.s	mt_tremset
mt_tremrmpdwn2	move.b	d0,d2
	bra.s	mt_tremset
mt_tremsine	move.b	(a3,d0.w),d2
mt_tremset	move.b	n_tremolocmd(a6),d0
	and.w	#$000F,d0
	mulu.w	d0,d2
	lsr.w	#6,d2
	moveq	#0,d0
	move.b	n_volume(a6),d0
	tst.b	n_tremolopos(a6)
	bmi.s	mt_tremneg
	add.w	d2,d0
	bra.s	mt_trem3
mt_tremneg	sub.w	d2,d0
mt_trem3	bpl.s	mt_tremskip3
	moveq	#0,d0
mt_tremskip3	moveq	#64,d6
	cmp.w	d6,d0
	bls.s	mt_tremok
	move.b	d6,d0
mt_tremok	move.w	d0,8(a5)
	move.b	n_tremolocmd(a6),d0
	lsr.w	#2,d0
	and.b	#$3C,d0
	add.b	d0,n_tremolopos(a6)
	rts


mt_sampoff	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	beq.s	mt_sononew
	move.b	d0,n_sampleoffset(a6)
mt_sononew	move.b	n_sampleoffset(a6),d0
	lsl.w	#7,d0
	cmp.w	n_length(a6),d0
	bge.s	mt_sofskip
	sub.w	d0,n_length(a6)
	add.w	d0,d0
	add.l	d0,n_start(a6)
	rts
mt_sofskip	moveq	#1,d0
	move.w	d0,n_length(a6)
	rts


mt_volumeslide	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	lsr.b	#4,d0
	beq.s	mt_volslidedown
mt_volslideup	add.b	d0,n_volume(a6)
	moveq	#64,d6
	cmp.b	n_volume(a6),d6
	bpl.s	mt_vsuskip
	move.b	d6,n_volume(a6)
mt_vsuskip	move.b	n_volume(a6),d0
	move.w	d0,8(a5)
	rts


mt_volslidedown	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	d7,d0
mt_volslidedown2 sub.b	d0,n_volume(a6)
	bpl.s	mt_vsdskip
	clr.b	n_volume(a6)
mt_vsdskip	move.b	n_volume(a6),d0
	move.w	d0,8(a5)
	rts


mt_posjump	move.b	n_cmdlo(a6),d0
	subq.b	#1,d0
	move.b	d0,mt_songpos-mt_base(a4)
mt_pj2	clr.b	mt_breakpos-mt_base(a4)
	st	mt_jmpflg-mt_base(a4)
	rts


mt_volchange	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	moveq	#64,d6
	cmp.b	d6,d0
	bls.s	mt_setvol
	move.b	d6,d0
mt_setvol	move.b	d0,n_volume(a6)
	move.w	d0,8(a5)
	rts


mt_pattbreak	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	move.l	d0,d2
	lsr.b	#4,d0
	move.w	d0,d6
	lsl.w	#3,d0
	add.w	d6,d0
	add.w	d6,d0
	and.b	d7,d2
	add.b	d2,d0
	moveq	#63,d6
	cmp.b	d6,d0
	bhi.s	mt_pj2
	move.b	d0,mt_breakpos-mt_base(a4)
	st	mt_jmpflg-mt_base(a4)
	rts


mt_checkefx2	bsr	mt_updatefunk
	move.b	n_cmd(a6),d0
	and.b	d7,d0
	moveq	#9,d6
	sub.b	d6,d0
	beq	mt_sampoff
	subq.b	#2,d0
	beq.s	mt_posjump
	subq.b	#1,d0
	beq.s	mt_volchange
	subq.b	#1,d0
	beq.s	mt_pattbreak
	subq.b	#1,d0
	beq.s	mt_ecomms
	IFEQ	NO_TEMPO
	subq.b	#1,d0
	bne	mt_periodnop
	move.b	n_cmdlo(a6),d0
	beq.s	mt_nospeed
	IFEQ	NO_MINMAX
	moveq	#TEMPO_MIN,d6
	cmp.b	d6,d0
	blt.s	mt_nospeed
	moveq	#TEMPO_MAX,d6
	cmp.b	d6,d0
	bgt.s	mt_nospeed
	ENDC
	clr.b	mt_counter-mt_base(a4)
	move.b	d0,mt_speed-mt_base(a4)
mt_nospeed	rts
	ENDC
	IFNE	NO_TEMPO
	bra	mt_periodnop
	ENDC


mt_ecomms	moveq	#0,d6
	move.b	n_cmdlo(a6),d6
	lsr.b	#4,d6
	moveq	#15,d2
	cmp.b	d2,d6
	bgt.s	mt_notused
	add.w	d6,d6
	lea	mt_jumptable-mt_base(a4),a2
	move.w	(a2,d6.w),d6
	jmp	(a2,d6.w)

mt_jumptable	dc.w	mt_togfilter-mt_jumptable
	dc.w	mt_fineporup-mt_jumptable
	dc.w	mt_finepordown-mt_jumptable
	dc.w	mt_stglissctrl-mt_jumptable
	dc.w	mt_stvibctrl-mt_jumptable
	dc.w	mt_stfinetune-mt_jumptable
	dc.w	mt_jumploop-mt_jumptable
	dc.w	mt_sttremctrl-mt_jumptable
	dc.w	mt_notused-mt_jumptable
	dc.w	mt_retrignote-mt_jumptable
	dc.w	mt_volfineup-mt_jumptable
	dc.w	mt_volfinedown-mt_jumptable
	dc.w	mt_notecut-mt_jumptable
	dc.w	mt_notedelay-mt_jumptable
	dc.w	mt_pattdelay-mt_jumptable
	dc.w	mt_funkit-mt_jumptable


mt_togfilter	move.b	n_cmdlo(a6),d0
	and.b	#1,d0
	add.b	d0,d0
	and.b	#$FD,$BFE001
	or.b	d0,$BFE001
mt_notused	rts


mt_stglissctrl	move.b	n_cmdlo(a6),d0
	and.b	d7,d0
	and.b	d5,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	rts


mt_stvibctrl	move.b	n_cmdlo(a6),d0
	and.b	d7,d0
	and.b	d5,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts


mt_stfinetune	move.b	n_cmdlo(a6),d0
	and.b	d7,d0
	move.b	d0,n_finetune(a6)
	rts


mt_jumploop	tst.b	mt_counter-mt_base(a4)
	bne.s	mt_nojploop
	move.b	n_cmdlo(a6),d0
	and.b	d7,d0
	beq.s	mt_setloop
	tst.b	n_loopcount(a6)
	beq.s	mt_jmpcnt
	subq.b	#1,n_loopcount(a6)
	beq.s	mt_nojploop
mt_jmploop	move.b	n_pattpos(a6),mt_breakpos-mt_base(a4)
	st	mt_break-mt_base(a4)
mt_nojploop	rts
mt_jmpcnt	move.b	d0,n_loopcount(a6)
	bra.s	mt_jmploop
mt_setloop	move.w	mt_pattpos-mt_base(a4),d0
	lsr.w	#4,d0
	move.b	d0,n_pattpos(a6)
	rts


mt_sttremctrl	move.b	n_cmdlo(a6),d0
	lsl.b	#4,d0
	and.b	d7,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts


mt_retrignote	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	d7,d0
	beq.s	mt_rtnend
	moveq	#0,d1
	move.b	mt_counter-mt_base(a4),d1
	bne.s	mt_rtnskip
	move.w	(a6),d2
	and.w	#$0FFF,d2
	bne.s	mt_rtnend
mt_rtnskip	divu.w	d0,d1
	swap	d1
	tst.w	d1
	bne.s	mt_rtnend
mt_retrig	move.w	n_dmabit(a6),$DFF096
	move.l	n_start(a6),(a5)
	move.w	n_length(a6),4(a5)
	bsr	mt_dmawait
	move.w	n_dmabit(a6),d0
	or.w	#$8000,d0
	move.w	d0,$DFF096
	bsr	mt_dmawait
	move.l	n_loopstart(a6),(a5)
	move.l	n_replen(a6),4(a5)
mt_rtnend	rts


mt_volfineup	tst.b	mt_counter-mt_base(a4)
	bne.s	mt_rts2
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	d7,d0
	bra	mt_volslideup


mt_volfinedown	tst.b	mt_counter-mt_base(a4)
	bne.s	mt_rts2
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	d7,d0
	bra	mt_volslidedown2


mt_notecut	move.b	n_cmdlo(a6),d0
	and.b	d7,d0
	cmp.b	mt_counter-mt_base(a4),d0
	bne.s	mt_rts2
	clr.b	n_volume(a6)
	clr.w	8(a5)
	rts


mt_notedelay	move.b	n_cmdlo(a6),d0
	and.b	d7,d0
	cmp.b	mt_counter-mt_base(a4),d0
	bne.s	mt_rts2
	tst.w	(a6)
	bne.s	mt_retrig
	rts


mt_pattdelay	tst.b	mt_counter-mt_base(a4)
	bne.s	mt_rts2
	tst.b	mt_patdeltime2-mt_base(a4)
	bne.s	mt_rts2
	move.b	n_cmdlo(a6),d0
	and.b	d7,d0
	addq.b	#1,d0
	move.b	d0,mt_patdeltime-mt_base(a4)
mt_rts2	rts


mt_funkit	tst.b	mt_counter-mt_base(a4)
	bne.s	mt_rts2
	and.b	d7,n_glissfunk(a6)
	move.b	n_cmdlo(a6),d0
	lsl.b	#4,d0
	beq.s	mt_rts2
	or.b	d0,n_glissfunk(a6)
mt_updatefunk	moveq	#0,d0
	move.b	n_glissfunk(a6),d0
	lsr.b	#4,d0
	beq.s	mt_rts2
	lea	n_funkoffset(a6),a2
	lea	mt_funktab-mt_base(a4),a1
	move.b	(a1,d0.w),d0
	add.b	d0,(a2)
	btst	#7,(a2)
	beq.s	mt_rts2
	clr.b	(a2)+
	move.l	n_loopstart(a6),d0
	moveq	#0,d2
	move.w	n_replen(a6),d2
	add.l	d2,d0
	add.l	d2,d0
	move.l	(a2),a1
	addq.w	#1,a1
	cmp.l	d0,a1
	blt.s	mt_funkok
	move.l	n_loopstart(a6),a1
mt_funkok	move.l	a1,(a2)
	not.b	(a1)
	rts


;*-----------------------------------------------------------------------------


mt_funktab	dc.b	0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

mt_vibtab	dc.b	0,24,49,74,97,120,141,161
	dc.b	180,197,212,224,235,244,250,253
	dc.b	255,253,250,244,235,224,212,197
	dc.b	180,161,141,120,97,74,49,24

mt_periodtab	dc.w	856,808,762,720,678,640,604,570,538,508,480,453 ;0
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450 ;1
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447 ;2
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444 ;3
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441 ;4
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437 ;5
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434 ;6
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431 ;7
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480 ;-8
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477 ;-7
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474 ;-6
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470 ;-5
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467 ;-4
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463 ;-3
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460 ;-2
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457 ;-1
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114

mt_voice1	dc.l	0,0,0,0,0,$10000,0,0,0,0,0
mt_voice2	dc.l	0,0,0,0,0,$20000,0,0,0,0,0
mt_voice3	dc.l	0,0,0,0,0,$40000,0,0,0,0,0
mt_voice4	dc.l	0,0,0,0,0,$80000,0,0,0,0,0
mt_samples	ds.l	31
mt_songdata	dc.l	0
mt_pattpos	dc.w	0
mt_dmacon	dc.w	0
mt_speed	dc.b	0
mt_counter	dc.b	0
mt_songpos	dc.b	0
mt_breakpos	dc.b	0
mt_jmpflg	dc.b	0
mt_break	dc.b	0
mt_lowmask	dc.b	0
mt_patdeltime	dc.b	0
mt_patdeltime2	dc.b	0,0
mt_base	ds.l	0
