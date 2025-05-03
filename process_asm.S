.global dispatch
.global go

.extern ReadyQ
.extern Running
dispatch:
    /* 
        This function will later be turned into a service/interrupt call.
        stack layout:
        x0
        x2
        ...
        x28
        x29
        x30
        PSTATE
    */

    // Save the context of the current process 
    sub     sp, sp, 16*16               // Make room for the process context

    // Save the proces general purpose registers

    stp	    x0, x1, [sp]
    stp     x2, x3, [sp, 16]
    stp     x4, x5, [sp, 16*2]
    stp     x6, x7, [sp, 16*3]
    stp     x8, x9, [sp, 16*4]
    stp     x10, x11, [sp, 16*5]
    stp     x12, x13, [sp, 16*6]
    stp     x14, x15, [sp, 16*7]
    stp     x16, x17, [sp, 16*8]
    stp     x18, x19, [sp, 16*9]
    stp     x20, x21, [sp, 16*10]
    stp     x22, x23, [sp, 16*11]
    stp     x24, x25, [sp, 16*12]
    stp     x26, x27, [sp, 16*13]
    stp     x28, x29, [sp, 16*14]
    str     x30, [sp, 16*15]

    mrs     x0, SPSR_EL1            // Save the process PSTATE
    str     x0, [sp, 16*15+8]

    // Enqueue the current process to the ready Q (call enqueue) 
    adr     x0, ReadyQ              // enqueue takes a pointer to the queue and 
    adr     x4, Running             //    a pointer to a PCB
    ldr     x4, [x4]                // put the first value in the PCB (the stack pointer) into x1 
    mov     x1, sp
    str     x1, [x4]                //    Then store the new top of stack that is now in x4 to the PCB 
    mov     x1, x4                  // Note: the first element in the pcb is the top of stack
    bl      enqueue                 // Put the current processes PCB into the ready Q

 
 go:
    // Dequeue the next process to run
    adr     x0, ReadyQ              // dequeue has one argument, the address of the ready Q
    bl      dequeue                 // call dequeue, x0 will have a ptr to the returned PCB
    adr     x1, Running             // We need to set the returned PCB as "running"
    str     x0, [x1]                // store the pointer to the PCB into the Running variable
    ldr     x2, [x0]                // x1 now has the value of the stack ptr (we cant ldr sp directly)
    mov	    sp, x2
    
    ldr     x0, [sp, 16*15+8]   // Restore PSTATE
    msr     SPSR_EL1, x0

    // retore process context
    ldp     x0, x1, [sp]
    ldp     x2, x3, [sp, 16]
    ldp     x4, x5, [sp, 16*2]
    ldp     x6, x7, [sp, 16*3]
    ldp     x8, x9, [sp, 16*4]
    ldp     x10, x11, [sp, 16*5]
    ldp     x12, x13, [sp, 16*6]
    ldp     x14, x15, [sp, 16*7]
    ldp     x16, x17, [sp, 16*8]
    ldp     x18, x19, [sp, 16*9]
    ldp     x20, x21, [sp, 16*10]
    ldp     x22, x23, [sp, 16*11]
    ldp     x24, x25, [sp, 16*12]
    ldp     x26, x27, [sp, 16*13]
    ldp     x28, x29, [sp, 16*14]
    ldr     x30, [sp, 16*15]
    add	    sp, sp, 16*16

    ret
