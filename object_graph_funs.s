    .include "graph_funs.s"
	.equ SCREEN_WIDTH,   640
	.equ SCREEN_HEIGH,   480
    .equ BITS_PER_PIXEL, 32

    //----------------------------------------------- paint_sun
    //
    // colorea circulos reduciendo su radio progrsivamente
    // y oscureciendo el color principal
    // centro del sol (x6,x5) | (x,y)
    //
    // por alguna razon no lo puedo hacer andar con un loop
paint_sun:
    sub sp,sp,#64                   // mem alloc
    
    str lr,[sp]                     // push to sp (stack pointer)
    str x5,[sp,#8]                  // push to sp x5 = Y
    str x6,[sp,#16]                 // push to sp x6 = X
    str x7,[sp,#24]                 // push to sp x7 = r^2
    str x8,[sp,#32]                 // push to sp x8 = r
    str x10,[sp,#40]                // push to sp color

    movz x10,#0x00ff,lsl 16         //color
    movk x10,#0xdaff                //color
    mov x8,120                      // radio
    mul x7,x8,x8                    // r^2
    mov x5, 240                     // pos Y
	mov x6, 110                     // pos X

    bl paint_circle

    sub x8,x8,#20                   // r
    mul x7,x8,x8                    // r^2
    movz x10,#0x00ff,lsl 16         //color
    movk x10,#0xc44e                //color

    bl paint_circle

    sub x8,x8,#20                   // r
    mul x7,x8,x8                    // r^2
    movz x10,#0x00ff,lsl 16         //color
    movk x10,#0xb829                //color

    bl paint_circle

    sub x8,x8,#10                   // r
    mul x7,x8,x8                    // r^2
    movz x10,#0x00ff,lsl 16         //color
    movk x10,#0xaa00                //color

    bl paint_circle

    ldr lr,[sp]                     // pop from sp
    ldr x5,[sp,#8]                  // pop from sp                
    ldr x6,[sp,#16]                 // pop from sp
    ldr x7,[sp,#24]                 // pop from sp
    ldr x8,[sp,#32]                 // pop from sp
    ldr x10,[sp,#40]                // pop from sp
    
    add sp,sp,#64
    ret
    //----------------------------------------------- end paint_sun 

    //----------------------------------------------- paint_sky_day
paint_sky_day:
    sub sp,sp,#64                   // mem alloc
    str lr,[sp]                     // push to sp (stack pointer)
    str x8,[sp,#8]                  // push to sp no me acuerdo (creo que no se usa en esta rutina)
    str x9,[sp,#16]                 // push to sp no me acuerdo (creo que no se usa en esta rutina)
    str x10,[sp,#24]                // push to sp color
    str x11,[sp,#32]                // push to sp offset lineas
    str x15,[sp,#40]                // push to sp Altura inicial lineas
    
    movz w10,#0x00ff,lsl 16         // color mas oscuro
    movk w10,#0xe573                //

    bl background_paint

    movz w10,#0x00ff,lsl 16         // color mas claro
    movk w10,#0xfa99                //

    bl upper_half                   // pinta solo la mitad para arriba

    movz w10,#0x00ff,lsl 16         // color mas oscuro
    movk w10,#0xe573                //

	mov x16,0                       // inicio lineas coord. X 
	mov x20,640                     // fin lineas coord. X
    mov x15,240                     // altura inixial lineas
    mov x11,0                       // offset lineas

loop_hor_lines:                     // en este loop se colorea de a 3 lineas, porque sino son muy finas, por eso 3 llamadas con un px de dif
    cbz x15, end_hor_line           //  while Y != 0
    bl paint_line_hr                //  pinta linea
    sub x15,x15,1                   //  disminuye la altura en Y
    bl paint_line_hr                //  idem
    sub x15,x15,1                   //  idem
    bl paint_line_hr                //  idem
    sub x15,x15,x11                 //  substrae el offset de la altura en Y para separacion entre lineas
    add x11,x11,2                   //  aumenta el offset de forma que las lineas esten cada vez mas dispersas
    b loop_hor_lines                //  fin loop
end_hor_line:

    ldr lr,[sp]                     // pop from sp
    ldr x8,[sp,#8]                  // pop from sp 
    ldr x9,[sp,#16]                 // pop from sp
    ldr x11,[sp,#24]                // pop from sp
    ldr x10,[sp,#32]                // pop from sp
    ldr x12,[sp,#40]                // pop from sp

    add sp,sp,#64                   // mem free
    ret
    //----------------------------------------------- end paint_sky_day

    //----------------------------------------------- paint_sky_night
    //
    //  idem paint_sky_day, solo difiere en colores
    //
paint_sky_night:
    sub sp,sp,#64
    str lr,[sp]
    str x16,[sp,#8]
    str x20,[sp,#16]
    str x10,[sp,#24]
    str x11,[sp,#32]
    str x15,[sp,#40]
    
    movz w10,#0x0002,lsl 16
    movk w10,#0x0052

    bl background_paint

    movz w10,#0x0027,lsl 16
    movk w10,#0x2654

    bl upper_half

    movz w10,#0x0002,lsl 16
    movk w10,#0x0052

    mov x16,0 
	mov x20,640
    mov x15,240                     
    mov x11,0                       

loop_hor_lines_n:
    cbz x15, end_hor_line_n
    bl paint_line_hr
    sub x15,x15,1
    bl paint_line_hr
    sub x15,x15,1
    bl paint_line_hr
    sub x15,x15,x11
    add x11,x11,2
    b loop_hor_lines_n

end_hor_line_n:

    ldr lr,[sp]
    ldr x8,[sp,#8]
    ldr x9,[sp,#16]
    ldr x11,[sp,#24]
    ldr x10,[sp,#32]
    ldr x12,[sp,#40]

    add sp,sp,#64
    ret
    //----------------------------------------------- end paint_sky_night
