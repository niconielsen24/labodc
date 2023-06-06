	.equ SCREEN_WIDTH,   640
	.equ SCREEN_HEIGH,   480
    .equ BITS_PER_PIXEL, 32


    //----------------------------------------------- background paint
background_paint:
    sub sp,sp,#32
    str lr,[sp]
    str x10,[sp,#8]

    movz x10, 0x001b, lsl 16 	//color blue
	movk x10, 0x2F62, lsl 00	//color blue

    mov x2, SCREEN_HEIGH         // Y Size
loop1:
	mov x1, SCREEN_WIDTH         // X Size
loop0:
	stur w10,[x0]				// Colorear el pixel N
	add x0,x0,4                 // Siguiente pixel
	sub x1,x1,1                 // Decrementar contador X
	cbnz x1,loop0               // Si no terminó la fila, salto
	sub x2,x2,1                 // Decrementar contador Y
	cbnz x2,loop1               // Si no es la última fila, salto
    
    ldr lr,[sp]
    ldr x10,[sp,#8]
    add sp,sp,#32
    ret
    //----------------------------------------------- end background paint


    //----------------------------------------------- paint circle
paint_circle:
    sub sp,sp,#32

    str lr,[sp]
    str x8,[sp,#8]
    str x9,[sp,#16]
    str x10,[sp,#24]

    movz x10, 0x00ff, lsl 16	//color white
	movk x10, 0xffff, lsl 00	//color white

    movz x8,0                // init a 0
    movz x9,0                // init a 0

    mov x2, SCREEN_HEIGH         // Y Size
loop1_crc:
	mov x1, SCREEN_WIDTH         // X Size
loop0_crc:
    sub x8,x5,x2                // dist en Y al centro
    sub x9,x6,x1                // dist en X al centro
    mul x8,x8,x8                // a^2 -- distancia en Y al cuadrado
    mul x9,x9,x9                // b^2 -- distancia en X al cuadrado
    add x9,x9,x8                // a^2 + b^2 -- suma del cuadrado de las distancias
    cmp x9,x7                   // comparo distancias con radio
    b.hi cont_crc               // si a^2 + b^2 > r^2 => (a,b) ∉  a la imagen
	stur w10,[x0]				// Colorear el pixel N
cont_crc:
    add x0,x0,4                 // Siguiente pixel
	sub x1,x1,1                 // Decrementar contador X
	cbnz x1,loop0_crc           // Si no terminó la fila, salto
	sub x2,x2,1                 // Decrementar contador Y
	cbnz x2,loop1_crc           // Si no es la última fila, salto  


    ldr x8,[sp,#8]
    ldr x9,[sp,#16]
    ldr x10,[sp,#24]  

    add sp,sp,#32
    ret
    //----------------------------------------------- end paint circle

    //----------------------------------------------- paint line - Bresenham
paint_line:
    sub sp,sp,#64                   // mem alloc
    str lr,[sp]
    //                                  x8 = px1
    //                                  x9 = py1
    //                                  x11 = px2
    //                                  x12 = py2
    str x13,[sp,#8]                 // push to sp  m -> pendiente
    str x14,[sp,#16]                // push to sp t -> auxiliar_pendiente
    str x15,[sp,#24]                // push to sp y
    str x16,[sp,#32]                // push to sp x

    //---------- calculo pendiente

    sub x14,x11,x8                  // px2-px1
    sub x13,x12,x9                  // py2-py1
    lsl x13,x13,1                   // round up m << 1
    udiv x13,x13,x14                // m = m/t

    //---------- init x,y

    mov x15,x9                      // x = px1
    mov x16,x8                      // y = py1

loop_line:
    cmp x11,x16                     // while px2 > x 
    b.le end_line                   // si px2 <= x end
    bl set_pixel                    // coloreo pixel (x,y)
    add x16,x16,1                   // x = x + 1
    add x15,x15,x13                 // y = y + m
    b loop_line

end_line:

    ldr x13,[sp,#8]                 //  pop from sp m
    ldr x14,[sp,#16]                //  pop from sp t
    ldr x15,[sp,#24]                //  pop from sp y
    ldr x16,[sp,#32]                //  pop from sp x

    add sp,sp,#64                   // mem free
    ret
    //----------------------------------------------- end paint line - Bresenham

    //----------------------------------------------- set_pixel
set_pixel:
    sub sp,sp,#40               // mem alloc

    str lr,[sp]                 // push to sp
    str x0,[sp,#8]              // push to sp
    str x1,[sp,#16]             // push to sp
    str x20,[sp,#24]            // 
    str x21,[sp,#32]

    mov x0,x23                  // x0 = FRAME_BUFFER
    //                          x8 =  px1
    //                          x15 = y
    //                          w10 = color   

    mov x20,x16
    mov x21,x15

    mov x1,SCREEN_WIDTH         // para poder usar instruccion mul
    mul x21,x21,x1              // multiplico posicion en y por la cantidad de pixeles en X para encontrar la altura correcta
    add x21,x21,x20              // sumo la posicion en X para obtener la celda correspondiente al punto
    lsl x21,x21,2               // multiplico el resultado por 4 para corresponder al lugar correcto en FRAME_BUFFER
    add x0,x0,x21               // finalmente corremos la base del FRAME_BUFFER al pixel deseado

    stur w10,[x0]               // coloreamos el pixel (x16,x15) | (x,y)

    ldr lr,[sp]                 // pop from sp
    ldr x0,[sp,#8]              // pop from sp
    ldr x1,[sp,#16]             // pop from sp
    ldr x20,[sp,#24]            // 
    ldr x21,[sp,#32]


    add sp,sp,#40               // free mem
    ret
    //----------------------------------------------- end set_pixel
