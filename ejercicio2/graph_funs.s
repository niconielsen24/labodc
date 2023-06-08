	.equ SCREEN_WIDTH,   640
	.equ SCREEN_HEIGH,   480
    .equ BITS_PER_PIXEL, 32

    //----------------------------------------------- lower half paint
upper_half:
    sub sp,sp,#32                   // mem alloc
    str lr,[sp]
    str x1,[sp,#8]
    str x2,[sp,#16]
    str x0,[sp,#24]

    mov x0,x23

    mov x2, SCREEN_HEIGH            // Y Size
    lsr x2,x2,1
loop_uh1: 
	mov x1, SCREEN_WIDTH            // X Size
loop_uh0:
	stur w10,[x0]				    // Colorear el pixel N
	add x0,x0,4                     // Siguiente pixel
	sub x1,x1,1                     // Decrementar contador X
	cbnz x1,loop_uh0                // Si no terminó la fila, salto
	sub x2,x2,1                     // Decrementar contador Y
	cbnz x2,loop_uh1                // Si no es la última fila, salto
    
    ldr lr,[sp]
    ldr x1,[sp,#8]
    ldr x2,[sp,#16]
    ldr x0,[sp,#24]
    add sp,sp,#32
    ret

    //----------------------------------------------- end lower falf paint


    //----------------------------------------------- background paint
background_paint:
    sub sp,sp,#32                   // mem alloc
    str lr,[sp]
    str x1,[sp,#8]
    str x2,[sp,#16]
    str x0,[sp,#24]

    mov x0,x23

    mov x2, SCREEN_HEIGH            // Y Size
loop1: 
	mov x1, SCREEN_WIDTH            // X Size
loop0:
	stur w10,[x0]				    // Colorear el pixel N
	add x0,x0,4                     // Siguiente pixel
	sub x1,x1,1                     // Decrementar contador X
	cbnz x1,loop0                   // Si no terminó la fila, salto
	sub x2,x2,1                     // Decrementar contador Y
	cbnz x2,loop1                   // Si no es la última fila, salto
    
    ldr lr,[sp]
    ldr x1,[sp,#8]
    ldr x2,[sp,#16]
    ldr x0,[sp,#24]
    add sp,sp,#32
    ret
    //----------------------------------------------- end background paint


    //----------------------------------------------- paint circle
paint_circle:
    sub sp,sp,#48                   // mem alloc

    str lr,[sp]
    str x8,[sp,#8]
    str x9,[sp,#16]
    str x1,[sp,#24]  
    str x2,[sp,#32]
    str x0,[sp,#40]  

    movz x8,0                       // init a 0
    movz x9,0                       // init a 0
    mov x0,x23

    mov x2, SCREEN_HEIGH            // Y Size
loop1_crc:  
	mov x1, SCREEN_WIDTH            // X Size
loop0_crc:
    sub x8,x5,x2                    // dist en Y al centro
    sub x9,x6,x1                    // dist en X al centro
    mul x8,x8,x8                    // a^2 -- distancia en Y al cuadrado
    mul x9,x9,x9                    // b^2 -- distancia en X al cuadrado
    add x9,x9,x8                    // a^2 + b^2 -- suma del cuadrado de las distancias
    cmp x9,x7                       // comparo distancias con radio
    b.hi cont_crc                   // si a^2 + b^2 > r^2 => (a,b) ∉  a la imagen
	stur w10,[x0]				    // Colorear el pixel N
cont_crc:   
    add x0,x0,4                     // Siguiente pixel
	sub x1,x1,1                     // Decrementar contador X
	cbnz x1,loop0_crc               // Si no terminó la fila, salto
	sub x2,x2,1                     // Decrementar contador Y
	cbnz x2,loop1_crc               // Si no es la última fila, salto  

    ldr lr,[sp]
    ldr x8,[sp,#8]
    ldr x9,[sp,#16]
    ldr x1,[sp,#24]  
    ldr x2,[sp,#32]
    ldr x0,[sp,#40]  


    add sp,sp,#48                   // free mem
    ret
    //----------------------------------------------- end paint circle

    //----------------------------------------------- paint line_hr
    //
    //
    //
paint_line_hr:
    sub sp,sp,#64                       // mem alloc
    str lr,[sp]                         // push to sp
    str x0,[sp,#8]                      // push to sp base FRAME_BUFFER
    str x18,[sp,#24]                    // push to sp altura Y
    str x17,[sp,#32]                    // push to sp auxiliar multiplicacion
    str x22,[sp,#16]                    // push to sp start X
    str x24,[sp,#48]                    // push to sp end X

    mov x22,x16                         // start X -- No modifica x16
    mov x24,x20                         // end X   -- No modifica x20
    mov x18,x15                         // altura Y-- No modifica x15
    mov x0,x23                          // base FRAME_BUFFER

    mov x17,SCREEN_WIDTH                // auxiliar multiplicacion
    mul x18,x18,x17                     // multiplicar Y por SCREEN_WIDTH nos da el primer pixel de la fila Y
    add x18,x18,x22                     // sumar X a Y nos da el pixel (x,y)
    lsl x18,x18,2                       // multiplicamos el resultado por 4 ya que cada pixel son 32bits = 4bytes

    add x0,x0,x18                       // sumamos el resultado a la base de FRAME_BUFFER
    sub x24,x24,x22                     // reutilizamos x24 nuevamente como contador para el ciclo, x24 - x22 = cantidad de px a colorear

loop_line:                              // en el loop se colorean x24 px a partir de x22 en la altura x18
    cbz x24,end_line                    // while x24 != 0
    stur w10,[x0]                       // colorea el base de FRAME_BUFFER
    add x0,x0,4                         // mueve la base de FRAME_BUFFER 1 px
    sub x24,x24,1                       // decrementa el contador
    b loop_line                         // fin loop
end_line:

    ldr lr,[sp]                         // pop from sp
    ldr x0,[sp,#8]                      // pop from sp
    ldr x18,[sp,#24]                    // pop from sp
    ldr x17,[sp,#32]                    // pop from sp
    ldr x22,[sp,#16]                    // pop from sp
    ldr x24,[sp,#48]                    // pop from sp                

    add sp,sp,#64                       // mem free
    ret
    //----------------------------------------------- end paint line_hr

    //----------------------------------------------- set_pixel
    //
    //  funciona pero no tiene uso  ^\(,_,)/^
    //
    // 
set_pixel:
    sub sp,sp,#40                   // mem alloc

    str lr,[sp]                     // push to sp
    str x0,[sp,#8]                  // push to sp
    str x1,[sp,#16]                 // push to sp
    str x20,[sp,#24]                // push to sp
    str x21,[sp,#32]    

    mov x0,x23                      // x0 = FRAME_BUFFER
    //                              x16 = x
    //                              x15 = y
    //                              w10 = color   

    mov x20,x16
    mov x21,x15

    mov x1,SCREEN_WIDTH             // para poder usar instruccion mul
    mul x21,x21,x1                  // multiplico posicion en y por la cantidad de pixeles en X para encontrar la altura correcta
    add x21,x21,x20                 // sumo la posicion en X para obtener la celda correspondiente al punto
    lsl x21,x21,2                   // multiplico el resultado por 4 para corresponder al lugar correcto en FRAME_BUFFER
    add x0,x0,x21                   // finalmente corremos la base del FRAME_BUFFER al pixel deseado

    stur w10,[x0]                   // coloreamos el pixel (x16,x15) | (x,y)

    ldr lr,[sp]                     // pop from sp
    ldr x0,[sp,#8]                  // pop from sp
    ldr x1,[sp,#16]                 // pop from sp
    ldr x20,[sp,#24]                // pop from sp
    ldr x21,[sp,#32]                // pop from sp


    add sp,sp,#40                   // free mem
    ret
    //----------------------------------------------- end set_pixel

    //----------------------------------------------- delay_loop_mov
delay_loop_mov:

    sub sp,sp,#16
    str lr,[sp]
    str x2,[sp,#8]

    mov x2,x1

loop_delay_mov:
	subs x2,x2,#1
	b.ne loop_delay_mov

    ldr lr,[sp]
    ldr x2,[sp,#8]
    
    add sp,sp,#16
    ret
    //----------------------------------------------- end delay_loop_mov

    //----------------------------------------------- delay_loop_GPIO
delay_loop_GPIO:

    sub sp,sp,#16
    str lr,[sp]
    str x1,[sp,#8]

    mov x1,x2

loop_delay_GPIO:
	subs x1,x1,#1
	b.ne loop_delay_GPIO

    ldr lr,[sp]
    ldr x1,[sp,#8]
    
    add sp,sp,#16
    ret
    //----------------------------------------------- end delay_loop_GPIO
