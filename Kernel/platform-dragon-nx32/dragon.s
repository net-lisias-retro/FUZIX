	;
	; common Dragon platform
	;

		.module dragon

		; exported

		; imported
		.globl unix_syscall_entry
		.globl fd_nmi_handler
		.globl size_ram
		.globl null_handler
		.globl _vid256x192
		.globl _vtoutput

		; exported debugging tools
		.globl _trap_monitor
		.globl outchar
		.globl _di
		.globl _ei
		.globl _irqrestore

            include "kernel.def"
            include "../kernel09.def"


		.area .vectors
	;
	;	At 0x100 as required by the Dragon ROM
	;
		    jmp badswi_handler			; 0x100
		    jmp badswi_handler			; 0x103
		    jmp unix_syscall_entry 		; 0x106
		    jmp fd_nmi_handler			; 0x109
		    jmp interrupt_handler		; 0x10C
		    jmp firq_handler			; 0x10F

	.area .text

init_early:
	ldx #null_handler
	stx 1
	lda #0x7E
	sta 0
	rts

init_hardware:
	jsr size_ram
	; Turn on PIA  CB1 (50Hz interrupt)
	lda 0xFF03
	ora #1
	sta 0xFF03
	jsr _vid256x192
	jsr _vtinit
	rts


; old p6809.s stuff below

            ; exported symbols
            .globl init_early
            .globl init_hardware
            .globl _program_vectors
	    .globl _need_resched


            ; imported symbols
            .globl _ramsize
            .globl _procmem
            .globl unix_syscall_entry
	    .globl fd_nmi_handler

            .area .common

_trap_reboot:
_trap_monitor:
	    cwai #0
	    bra _trap_monitor


_di:
	    tfr cc,b		; return the old irq state
	    orcc #0x10
	    rts
_ei:
	    andcc #0xef
	    rts

_irqrestore:			; B holds the data
	    tfr b,cc
	    rts

            .area .text


;
;------------------------------------------------------------------------------
; COMMON MEMORY PROCEDURES FOLLOW


            .area .common

;
;	In the Dragon nx32 case our vectors live in a fixed block
; 	and is not banked out.
;
_program_vectors:
	    rts

;
;	FIXME:
;
firq_handler:
badswi_handler:
	    rti

; outchar: Simple writing to video memory
; FIXME: bank switching ???
outchar:
	    pshs x,d,pc
	    sta outbuf
	    ldx #outbuf
	    lda #1
	    pshs a
	    jsr _vtoutput
	    puls x,d,pc

	    .area .common

outbuf:	    .db 0
_need_resched: .db 0
