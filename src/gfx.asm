;65C02 instruction set
.pc02

;Commander X16 definitions
.include "cx16.inc"

;Kernal subroutines and definitions
.include "x16kernal.inc"

.bss
irq_default:        .res 2      ;Default isr (Kernal handler)
row_size:           .res 1      ;What scale to set the screen at the split section
wave_idx:           .res 1      ;Index of the 'wavetable'
line_irq_cnt:       .res 1      ;To indicate what part of the split we are at
irq_skip_default:   .res 1      ;Whether the default interrupt handler is to be skipped

;Constants
SPLIT_1         = $80
SPLIT_2         = $C0
SCALE_DEFAULT   = $80

.code

;Procedure to initialize the custom Interrupt handler (ISR)
;and save the address of the default handler to restore later.
;Called externally (in C)
.export _initirq
.proc _initirq
    ;Copy the address of the original (Kernal) ISR
    lda IRQVec
    sta irq_default
    lda IRQVec+1
    sta irq_default+1

    ;Disable interrupts while we are changing the ISR address
    sei
    ;Set-up the address of the custom ISR
    lda #<irq_handler
    sta IRQVec
    lda #>irq_handler
    sta IRQVec+1
    ;Enable interrupts again
    cli

    rts
.endproc

;Procedure to restore back the default interrupt handler
.export _restoreirq
.proc _restoreirq
    ;Load back the original isr
    sei
    lda irq_default
    sta IRQVec
    lda irq_default+1
    sta IRQVec+1
    cli

    ;Restore the screen
    jsr CONSOLE_init

    rts
.endproc

;Initialize the VERA video registers for proper interrupts
.export _initvera
.proc _initvera
    ;Clear the screen
    lda #CH::SCRN_CLEAR
    jsr CHROUT

    sei
    ;Enable V-Blank and Line interrupts
    lda #(VERA::VERT_SYNC | VERA::RASTER_IRQ)
    sta VERA::IRQ_EN
    
    ;First screen split line number
    lda #SPLIT_1
    sta VERA::IRQ_RASTER
    sta row_size
    cli

    stz wave_idx

    rts
.endproc

;Custom interrupt handler
.proc irq_handler
    stz irq_skip_default
    ;Check what type of interrupt
    lda VERA::IRQ_FLAGS
@check_vsync:
    and #VERA::VERT_SYNC
    beq @check_line

    ;[V-SYNC irq]
    ;Reset the interrupt flag
    lda #VERA::VERT_SYNC
    sta VERA::IRQ_FLAGS

    ;Every frame, reset the raster interrupt line
    lda #SPLIT_1
    sta VERA::IRQ_RASTER
    stz line_irq_cnt

    ;Default scale
    lda #SCALE_DEFAULT
    sta VERA::DISP::HSCALE

    ;Change size of the middle section
    ldx wave_idx
    lda sin_table, x
    sta row_size
    
    ;Next value in the table. It will overflow and loop after 256 iterations
    inc wave_idx

@check_line:
    lda VERA::IRQ_FLAGS
    and #VERA::RASTER_IRQ
    beq @irq_end
    inc irq_skip_default

    ;[Line irq]
    ;Reset the interrupt flag
    lda #VERA::RASTER_IRQ
    sta VERA::IRQ_FLAGS

    ;Check section of the screen
    lda line_irq_cnt
    bne @last_section
    inc line_irq_cnt

    ;First section
    ;Adjust scale of the screen, according to the value
    lda row_size
    sta VERA::DISP::HSCALE

    ;Fire another interrupt after some lines
    lda #SPLIT_2
    sta VERA::IRQ_RASTER

    ;Skip the last_section part
    bra @irq_end
@last_section:
    ;Restore scale
    lda #SCALE_DEFAULT
    sta VERA::DISP::HSCALE
@irq_end:
    lda irq_skip_default
    bne @normal_irq_exit
    jmp (irq_default)
@normal_irq_exit:
    ;Restore CPU registered pushed by the BIOS ISR
    ply
    plx
    pla
    rti
.endproc


.rodata
sin_table: .incbin "obj/sintable.bin"
