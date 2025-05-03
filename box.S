// draw a box:
// +-------------+
// |             |
// |             |
// +-------------+
// int box(unsigned int sr, unsigned int sc, unsigned int er, unsigned int ec);


.extern     term_txtheight
.extern     term_txtwidth
.extern     print_to  
.extern     putc_to 

.global     box
box:
 
    // standard entry: save link and stack frame registers
    //    load the stack frame with the pointer to current frame
    stp     x29, x30, [sp, -16]!

    // Save the arguments.  Called functions may overwrite x0-x3
    sub     sp, sp, 32
    stp     x0, x1, [sp]
    stp     x2, x3, [sp, 16]

    // sr in w0, sc in w1, er int w2, ec in w3
    
    // Make sure the argument are valid

    bl      _box_check_box_
    cmp     w0, 0
    bne     _box_error_

 
    // first, draw the corners:
    // +        +
    // +        +
    ldp     x0, x1, [sp]
    ldp     x2, x3, [sp, 16]
    bl      _box_draw_corners_

    // Now, draw the top and bottom:
    // +------+
    // +------+
    ldp     x0, x1, [sp]
    ldp     x2, x3, [sp, 16]
    bl      _box_draw_top_bottom_   

    // draw left and right sides
    ldp     x0, x1, [sp]
    ldp     x2, x3, [sp, 16]
    bl      _box_draw_sides_

    mov     w0, 0
    b       _box_exit_

_box_error_:
    mov     w0, 1

_box_exit_:
    add     sp, sp, 32   // pop save arg regs

    ldp     x29, x30, [sp], 16
    ret


_box_check_box_:

    // standard entry: save link and stack frame registers
    //    load the stack frame with the pointer to current frame
    stp     x29, x30, [sp, -16]!

    // save our parameters away because we call functions
    //   that may destroy them
    sub     sp, sp, 32
    stp     x0, x1, [sp]
    stp     x2, x3, [sp, 16]

    // A box cannot be drawn if:
    //      the begining of the box is off he screen
    //      the end of the box is off the screen
    //      the end of the box is before he begginning
    //

    // get the height and width of the screen in characters
    // temporarily save w0
    bl      term_txtheight
    mov     w4, w0
    bl      term_txtwidth
    mov     w5, w0
    

    // make sure box is not off the screen
    ldr     x0, [sp]
    cmp     w0, 0
    blt      _box_check_error_
    cmp     w0, w4
    bge     _box_check_error_
    ldr     w1, [sp, 8]
    cmp     w1, 0
    blt     _box_check_error_
    cmp     w1, w5
    bge     _box_check_error_

    // check that the lower right corner is below and
    //   to the right of the upper left corner
    cmp     w0, w2
    bge     _box_check_error_
    cmp     w1, w3
    bge     _box_check_error_

    mov     x0, 0
    b       _box_check_exit_

_box_check_error_:
    mov     w0, 1
_box_check_exit_:
    add     sp, sp, 32   // pop save arg regs
    ldp     x29, x30, [sp], 16
    ret
    

_box_draw_corners_:

    // standard entry: save link and stack frame registers
    //    load the stack frame with the pointer to current frame
    stp     x29, x30, [sp, -16]!

    // save our parameters away because we call functions
    //   that may destroy them
    sub     sp, sp, 32
    stp     x0, x1, [sp]
    stp     x2, x3, [sp, 16]
   // upper corners

    ldr     x0, [sp]
    ldr     x1, [sp, 8]
    mov     w2, '+'
    bl      putc_to
    ldr     x0, [sp]
    ldr     w1, [sp, 24]
    mov     w2, '+'
    bl      putc_to

    // draw the lower corners
    ldr     x0, [sp, 16]
    ldr     x1, [sp, 8]
    mov     w2, '+'
    bl      putc_to
    ldr     x0, [sp, 16]
    ldr     w1, [sp, 24]
    mov     w2, '+'
    bl      putc_to

    add     sp, sp, 32   // pop save arg regs
    ldp     x29, x30, [sp], 16
    ret

_box_draw_top_bottom_:
    // standard entry: save link and stack frame registers
    //    load the stack frame with the pointer to current frame
    stp     x29, x30, [sp, -16]!

    //  x19-x23 are saved to the stack (responsib-
    //    ility of the callee to save these)
    //  and x0-x3 are saved to the stack (calls
    //    to procedures may destroy our arguments)
  
    //  note, must restore x19-x23 before exiting

    sub     sp, sp, 48
    stp     x19, x20, [sp]
    stp     x21, x22, [sp, 16]
    str     x23, [sp, 32]

    sub     sp, sp, 32
    stp     x0, x1, [sp]
    stp     x2, x3, [sp, 16]

    // draw line between upper corners
    ldr     x19, [sp]
    ldr     x20, [sp, 8]
    add     x20, x20, 1
    mov     w21, '-'
    ldr     x22, [sp, 24]
_box_topbottom_toploop_:
    mov     x0, x19
    mov     x1, x20
    mov     w2, w21
    bl      putc_to
    add     x20, x20, 1
    cmp     x20, x22
    blt     _box_topbottom_toploop_ 


    // draw line between the lower corneres
    ldr    x19, [sp, 16]
    ldr    x20, [sp, 8]
    add    x20, x20, 1
_box_topbottom_bottomloop_:
    mov     x0, x19
    mov     x1, x20
    mov     w2, w21
    bl      putc_to
    add     x20, x20, 1
    cmp     x20, x22
    blt     _box_topbottom_bottomloop_   

    add     sp, sp, 32   // pop  save arg regs

    // restore saved x19-x23
    ldp     x19, x20, [sp], 16
    ldp     x21, x22, [sp], 16
    ldr     x23, [sp], 16   

    ldp     x29, x30, [sp], 16
    ret

_box_draw_sides_:

    // standard entry: save link and stack frame registers
    //    load the stack frame with the pointer to current frame
    stp     x29, x30, [sp, -16]!

    //  x19-x23 are saved to the stack (responsib-
    //    ility of the callee to save these)
    //  and x0-x3 are saved to the stack (calls
    //    to procedures may destroy our arguments)
  
    //  note, must restore x19-x23 before exiting

    sub     sp, sp, 48
    stp     x19, x20, [sp]
    stp     x21, x22, [sp, 16]
    str     x23, [sp, 32]

    sub     sp, sp, 32
    stp     x0, x1, [sp]
    stp     x2, x3, [sp, 16]

    ldr     x19, [sp]       // sr
    add     x19, x19, 1     // sr + 1
    ldr     x23, [sp, 16]   // er
    ldr     x20, [sp, 8]    // sc
    mov     w21, '|'
    ldr     x22, [sp, 24]
_box_drawsides_rightleft_:
    mov     x0, x19
    mov     x1, x20
    mov     w2, w21
    bl      putc_to
    mov     x0, x19
    mov     x1, x22
    mov     w2, w21
    bl      putc_to
    add     x19, x19, 1
    cmp     x19, x23
    blt     _box_drawsides_rightleft_

    add     sp, sp, 32   // pop  save arg regs

    // restore saved x19-x23
    ldp     x19, x20, [sp], 16
    ldp     x21, x22, [sp], 16
    ldr     x23, [sp], 16   

    ldp     x29, x30, [sp], 16
    ret

    