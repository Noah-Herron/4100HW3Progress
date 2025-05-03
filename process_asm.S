.global dispatch
.global go
.global setup_EVT
.global init_timer
.global clear_timer
.global unsupported

.extern ReadyQ
.extern Running
.extern unsupported_handler


dispatch:
    // Disable interrupts (DAIFSet = 0x2 disables IRQs)
    msr     DAIFSet, #0x2

    // Save x1 temporarily to EL1 stack
    str     x1, [sp, -16]!

    // Get process stack pointer from system register SP_EL0 into x1
    mrs     x1, SP_EL0

    // Make space for 17 16-byte entries (x0–x30, PSTATE, ELR)
    sub     x1, x1, 16 * 17

    // Save general purpose registers onto the process stack
    stp     x0, x1, [sp, -16]!
    ldr x0, [sp]
    mov x2, x1
    add x1, sp, 16
    ldr x1, [x1]
    stp x0, x1, [x2]
    ldp x0, x1, [sp], 16

    // store registers x2...x30 on the stack (using x1 as destion)
    stp x2, x3, [x1, 16]
    stp x4, x5, [x1, 16*2]
    stp x6, x7, [x1, 16*3]
    stp x8, x9, [x1, 16*4]
    stp x10, x11, [x1, 16*5]
    stp x12, x13, [x1, 16*6]
    stp x14, x15, [x1, 16*7]
    stp x16, x17, [x1, 16*8]
    stp x18, x19, [x1, 16*9]
    stp x20, x21, [x1, 16*10]
    stp x22, x23, [x1, 16*11]
    stp x24, x25, [x1, 16*12]
    stp x26, x27, [x1, 16*13]
    stp x28, x29, [x1, 16*14]
    str x30, [x1, 16*15]

    // Save PSTATE
    mrs     x0, SPSR_EL1
    str     x0, [x1, 16*15 + 8]

    // Save Exception return address
    mrs     x0, ELR_EL1
    str     x0, [x1, 16*16]

    // Save value of x1 into pcb
    adr x0, ReadyQ  // take pointer to queue
    adr x4, Running          // pointer to pcb
    ldr x4, [x4]          // puts first value in pcb

    // Restore saved x1 (was saved to EL1 stack)
    str x1, [x4]     // store new stack pointer on stack
    mov x1, x4       // move pcb pointer to x1 for enqueue

    // Enqueue the current process

    bl enqueue
    b go  



go:
    // Dequeue the next process to run
    adr     x0, ReadyQ              // dequeue has one argument, the address of the ready Q
    bl      dequeue                 // call dequeue, x0 will have a ptr to the returned PCB
    adr     x1, Running             // We need to set the returned PCB as "running"
    str     x0, [x1]                // store the pointer to the PCB into the Running variable
    ldr     x1, [x0]        // Load user stack pointer from PCB

    
    ldr x0, [x1, 16*15+8]   // Restore PSTATE
    msr     SPSR_EL1, x0

    ldr x0, [x1, 16*16]
    msr ELR_EL1, x0

    //store new top of stack
    mov x0, x1
    add x0, x0, 16*17
    msr SP_EL0, x0

    // retore process registers
    ldp     x2, x3, [x1, 16]
    ldp     x4, x5, [x1, 16*2]
    ldp     x6, x7, [x1, 16*3]
    ldp     x8, x9, [x1, 16*4]
    ldp     x10, x11, [x1, 16*5]
    ldp     x12, x13, [x1, 16*6]
    ldp     x14, x15, [x1, 16*7]
    ldp     x16, x17, [x1, 16*8]
    ldp     x18, x19, [x1, 16*9]
    ldp     x20, x21, [x1, 16*10]
    ldp     x22, x23, [x1, 16*11]
    ldp     x24, x25, [x1, 16*12]
    ldp     x26, x27, [x1, 16*13]
    ldp     x28, x29, [x1, 16*14]

    // temp save x0 and x1
    stp x0, x1, [sp, -16]!

    // clear counter and reset timer
    bl clear_timer

    // restore x0 and x1
    ldp x0, x1, [sp], 16

    // restore x30
    ldr x30, [x1, 16*15]

    //restore x0 and x1 (final registers?)
    ldp x0, x1, [x1]

    // enable interupts
    msr DAIFClr, #0x2

    eret

// -----------------------------
// setup_EVT: set VBAR_EL1
// -----------------------------
setup_EVT:
    adr x0, vector_table
    msr VBAR_EL1, x0
    ret

// -----------------------------
// init_timer: route interrupt, enable timer
// -----------------------------
init_timer:
    stp x29, x30, [sp, -16]!
    bl clear_timer
    ldr x0, =0x40000040
    mov x1, 0x08
    str w1, [x0]
    mov x0, 1
    msr CNTV_CTL_EL0, x0
    ldp x29, x30, [sp], 16
    ret

// -----------------------------
// clear_timer: set timer for 1/20 sec
// -----------------------------
clear_timer:
    mrs x0, CNTFRQ_EL0
    mov x1, 20
    udiv x0, x0, x1
    msr CNTV_TVAL_EL0, x0
    ret

// -----------------------------
// unsupported: default trap handler
// -----------------------------
unsupported:
    mov x0, #0
    mov x1, #0
    bl unsupported_handler
    b .

// -----------------------------
// vector_table: interrupt vectors
// -----------------------------
; .align 7
vector_table:
    .balign 128
        b unsupported
    .balign 128
        b dispatch
    .balign 128
        b unsupported
    .balign 128
        b unsupported
    .balign 128
        b unsupported
    .balign 128
        b dispatch    // yes
    .balign 128
        b unsupported
    .balign 128
        b unsupported
    .balign 128
        b unsupported
    .balign 128
        b dispatch
    .balign 128
        b unsupported
    .balign 128
        b unsupported
    .balign 128
        b unsupported
    .balign 128
        b dispatch
    .balign 128
        b unsupported
    .balign 128
        b unsupported 

