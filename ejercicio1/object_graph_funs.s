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
paint_sun:
    sub sp,sp,#48                   // mem alloc
    
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
    
    add sp,sp,#48
    ret
    //----------------------------------------------- end paint_sun 

    //----------------------------------------------- paint_moon
    //
    //
    //  -- idem paint_sun --  
    //
    //
paint_moon:
    sub sp,sp,#48                   // mem alloc
    str lr,[sp]                     // push to sp
    str x5,[sp,#8]                  // push to sp
    str x6,[sp,#16]                 // push to sp
    str x7,[sp,#24]                 // push to sp
    str x8,[sp,#32]                 // push to sp
    str x10,[sp,#40]                // push to sp

    // CIRCULOS LUNA

    movz w10,#0x00ff,lsl 16
    movk w10,#0xffff

    mov x5,400                      // Y
    mov x6,550                      // X

    mov x8,80                       // r
    mul x7,x8,x8                    // r^2

    bl paint_circle

    movz w10,#0x00df,lsl 16         // color
    movk w10,#0xdfdf                //  --

    sub x8,x8,5                     // disminuyo radio
    mul x7,x8,x8                    // r^2

    bl paint_circle

    movz w10,#0x00bf,lsl 16         // color
    movk w10,#0xbfbf                //  --

    sub x8,x8,20                    // disminuyo radio
    mul x7,x8,x8                    // r^2

    bl paint_circle

    ldr lr,[sp]                     // pop from sp
    ldr x5,[sp,#8]                  // pop from sp
    ldr x6,[sp,#16]                 // pop from sp
    ldr x7,[sp,#24]                 // pop from sp
    ldr x8,[sp,#32]                 // pop from sp
    ldr x10,[sp,#40]                // pop from sp

    add sp,sp,#48                   // mem free
    ret
    //----------------------------------------------- end paint_moon 


    //----------------------------------------------- paint_sky_day
    //
    //  Pinta la mitad inferior de la pantalla de naranja 0xffe573 
    //  Pinta la mitad superior de la pantalla de naranja 0xfffa99
    //  pinta rayas en base a paint_line_hr de color naranja 0xffe573 en la parte superior
    //
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
    sub sp,sp,#64                               // alloc mem
    str lr,[sp]                                 // push to sp
    str x16,[sp,#8]                             // push to sp
    str x20,[sp,#16]                            // push to sp
    str x10,[sp,#24]                            // push to sp
    str x11,[sp,#32]                            // push to sp
    str x15,[sp,#40]                            // push to sp
    

    movz w10,#0x0019,lsl 16                     //
    movk w10,#0x1919                            //

    bl background_paint                         //

    movz w10,#0x004e,lsl 16                     //
    movk w10,#0x3f2d                            //

    bl upper_half                               //

    movz w10,#0x0019,lsl 16                     //
    movk w10,#0x1919                            //

    mov x16,0                                   //
	mov x20,640                                 //
    mov x15,240                                 //                    
    mov x11,0                                   //                

loop_hor_lines_n:                               //
    cbz x15, end_hor_line_n                     //
    bl paint_line_hr                            //
    sub x15,x15,1                               //
    bl paint_line_hr                            //
    sub x15,x15,1                               //
    bl paint_line_hr                            //
    sub x15,x15,x11                             //
    add x11,x11,2                               //
    b loop_hor_lines_n                          //

end_hor_line_n:                                 //

    ldr lr,[sp]                                 // pop from sp
    ldr x8,[sp,#8]                              // pop from sp
    ldr x9,[sp,#16]                             // pop from sp
    ldr x11,[sp,#24]                            // pop from sp
    ldr x10,[sp,#32]                            // pop from sp
    ldr x12,[sp,#40]                            // pop from sp

    add sp,sp,#64                               // mem free
    ret
    //----------------------------------------------- end paint_sky_night

    //----------------------------------------------- paint fore_ground
    //
    //  en base a line_hr se colorean progresivamente lineas para formar el terreno
    //
fore_ground:
    sub sp,sp,#64                               // mem alloc

    str lr,[sp]                                 // push to sp 
    str x10,[sp,#8]                             // push to sp 
    str x8,[sp,#16]                             // push to sp 
    str x9,[sp,#24]                             // push to sp 
    str x15,[sp,#32]                            // push to sp
    str x16,[sp,#40]                            // push to sp color 
    str x20,[sp,#80]                            // push to sp 


    movz w10, #0x0026,lsl 16                    // color
    movk w10, #0x5430                           // --


    mov x16,600                                 // movemos a x16(start X) el valor 600
    mov x20,640                                 // movemos a x20(end X)   el valor 640
    mov x15,270                                 // movemos Y1 a x15(altura de linea)

    mov x8,6                                    // contador filas
    mov x9,70                                   // offset inicial start X

loop_fore_ground_0:
    cmp x15,480                                 // while x15 != ultima fila
    b.eq det_lines_R                            // si x15 == 480 fin loop
    bl paint_line_hr                            // colorea linea
    add x15,x15,1                               // siguiente fila
    sub x8,x8,1                                 // decrementa contador filas
    cbnz x8,loop_fore_ground_0                  // while x8 != vuelvo al inicio
    mov x8,6                                    // reinicio contador filas
    sub x16,x16,x9                              // restamos el offset a start X
    cmp x9,0                                    //  --
    b.le loop_fore_ground_0                     // si el offset es <= 0 no lo seguimos reduciendo
    sub x9,x9,4                                 // reducimos el offset
    b loop_fore_ground_0                        // fin loop

det_lines_R:                                    // pinta lineas de color distinto para gregar detalle

    mov x16,600                                 // movemos a x16(start X) el valor 600
    mov x20,640                                 // movemos a x20(end X)   el valor 640
    mov x15,270                                 // movemos Y1 a x15(altura de linea)

    movz w10, #0x0038,lsl 16                    //  cambio color
    movk w10, #0x7144                           //  --

    mov x8,6                                    // contador filas
    mov x9,70                                   // offset inicial start X

det_lines_0:                                    // idem loop anterior, que colorea una linea cada x8
    cmp x15,480                                 //  --  
    b.eq cont_foreground                        //  --
    add x15,x15,1                               //  -- 
    sub x8,x8,1                                 //  --  
    cbnz x8,det_lines_0                         //  --  
    bl paint_line_hr                            //  -- 
    mov x8,6                                    //  --  
    sub x16,x16,x9                              //  --  
    cmp x9,0                                    //  --
    b.le det_lines_0                            //  -- 
    sub x9,x9,4                                 //  -- 
    b det_lines_0                               //  -- 

cont_foreground:

    movz w10, #0x0038,lsl 16                    // cambio color
    movk w10, #0x7144                           //  --

    mov x16,0                                   // movemos a x16(start X) el valor 0
    mov x20,2                                   // movemos a x20(end X)   el valor 2
    mov x15,280                                 // movemos Y1 a x15(altura de linea)

    mov x8,5                                    // contador filas
    mov x9,60                                   // offset inicial start X

loop_fore_ground_1:                             // idem loop_fore_ground_0
    cmp x15,480                                 //  --
    b.eq det_lines_L                            //  --
    bl paint_line_hr                            //  --
    add x15,x15,1                               //  -- 
    sub x8,x8,1                                 //  --
    cbnz x8,loop_fore_ground_1                  //  --
    mov x8,5                                    //  --
    add x20,x20,x9                              //  --
    cmp x9,0                                    //  --
    b.le loop_fore_ground_1                     //  --
    sub x9,x9,2                                 // cambia el factor de reduccion
    b loop_fore_ground_1                        //  --

det_lines_L:                                    // idem det_lines_R

    movz w10, #0x0026,lsl 16                    // color
    movk w10, #0x5430                           //  --

    mov x16,0                                   //  --
    mov x20,2                                   //  --
    mov x15,280                                 //  -- 

    mov x8,5                                    //  --
    mov x9,60                                   //  --

det_lines_1:                                    // idem det_lines_0
    cmp x15,480                                 //  --
    b.eq end_foreground                         //  --
    add x15,x15,1                               //  -- 
    sub x8,x8,1                                 //  --
    cbnz x8,det_lines_1                         //  --
    bl paint_line_hr                            //  --
    mov x8,5                                    //  --
    add x20,x20,x9                              //  --
    cmp x9,0                                    //  --
    b.le det_lines_1                            //  --
    sub x9,x9,2                                 //  --
    b det_lines_1                               //  --

end_foreground:
    ldr lr,[sp]                                 // pop from sp
    ldr x10,[sp,#8]                             // pop from sp                             
    ldr x8,[sp,#16]                             // pop from sp                             
    ldr x9,[sp,#24]                             // pop from sp                             
    ldr x15,[sp,#32]                            // pop from sp                             
    ldr x16,[sp,#40]                            // pop from sp                             
    ldr x20,[sp,#48]                            // pop from sp                             

    add sp,sp,#64                               // free mem
    ret
    //----------------------------------------------- end paint_fore_ground

    //----------------------------------------------- paint_casita
paint_casita:
    sub sp,sp,#40
    str lr,[sp]                                     // push to sp
    str x10,[sp,#8]                                 // push to sp
    str x15,[sp,#16]                                // push to sp
    str x16,[sp,#24]                                // push to sp
    str x20,[sp,#32]                                // push to sp

    mov x16,500                                     // start_line X
    mov x20,580                                     // end_line X
    mov x15,260                                     // altura inicial Y

    movz w10,#0x00bb,lsl 16                         //
    movk w10,#0x9766                                //

loop_casita_princ:                                  //
    cmp x15,300                                     //
    b.eq end_casita_princ                           //
    bl paint_line_hr                                //
    add x15,x15,1                                   //
    b loop_casita_princ                             //
end_casita_princ:                                   //

    movz w10,#0x0095,lsl 16                         //
    movk w10,#0x7850                                //

    mov x16,480                                     // start_line X
    mov x20,500                                     // end_line X
    mov x15,240                                     // altura inicial Y

loop_casita_front:                                  //
    cmp x15,300                                     //
    b.eq end_casita_front                           //
    bl paint_line_hr                                //
    add x15,x15,1                                   //
    b loop_casita_front                             //

end_casita_front:                                   //

    movz w10,#0x0097,lsl 16                         //
    movk w10,#0x641f                                //

    mov x16,485                                     // start_line X
    mov x20,495                                     // end_line X
    mov x15,280                                     // altura inicial Y

loop_casita_puerta:                                 //
    cmp x15,300                                     //
    b.eq end_casita_puerta                          //
    bl paint_line_hr                                //
    add x15,x15,1                                   //
    b loop_casita_puerta                            //

end_casita_puerta:                                  //

    movz w10,#0x00ff,lsl 16                         //
    movk w10,#0xffff                                //

    mov x16,510                                     // start_line X
    mov x20,530                                     // end_line X
    mov x15,275                                     // altura inicial Y

loop_casita_ventana_0:                              //
    cmp x15,295                                     //
    b.eq end_casita_ventana_0                       //
    bl paint_line_hr                                //
    add x15,x15,1                                   //
    b loop_casita_ventana_0                         //

end_casita_ventana_0:                               //

    mov x16,550                                     // start_line X
    mov x20,570                                     // end_line X
    mov x15,275                                     // altura inicial Y

loop_casita_ventana_1:                              //
    cmp x15,295                                     //
    b.eq end_casita_ventana_1                       //
    bl paint_line_hr                                //
    add x15,x15,1                                   //
    b loop_casita_ventana_1                         //

end_casita_ventana_1:                               //

    movz w10,#0x005a,lsl 16                         //
    movk w10,#0x1f15                                //

    mov x16,480                                     // start_line X
    mov x20,500                                     // end_line X
    mov x15,240                                     // altura inicial Y

loop_casita_techo_back:                             //
    cmp x15,260                                     //
    b.eq end_casita_techo_back                      //
    bl paint_line_hr                                //
    add x15,x15,1                                   //
    sub x16,x16,1                                   //
    sub x20,x20,1                                   //
    b loop_casita_techo_back                        //

end_casita_techo_back:                              //

    movz w10,#0x0097,lsl 16                         //
    movk w10,#0x2f1f                                //

    mov x16,480                                     // start_line X
    mov x20,580                                     // end_line X
    mov x15,240                                     // altura inicial Y

loop_casita_techo_princ:                            //
    cmp x15,260                                     //
    b.eq end_casita_techo_princ                     //
    bl paint_line_hr                                //
    add x15,x15,1                                   //
    add x16,x16,1                                   //
    add x20,x20,1                                   //
    b loop_casita_techo_princ                       //

end_casita_techo_princ:                             //

    mov x16,560                                     // start_line X
    mov x20,570                                     // end_line X
    mov x15,225                                     // altura inicial Y

    movz w10,#0x0050,lsl 16                         //
    movk w10,#0x4645                                //

loop_casita_chim:                                   //
    cmp x15,250                                     //
    b.eq end_casita_chim                            //
    bl paint_line_hr                                //
    add x15,x15,1                                   //
    b loop_casita_chim                              //

end_casita_chim:                                    //

    ldr lr,[sp]                                     //
    ldr x10,[sp,#8]                                 //
    ldr x15,[sp,#16]                                //
    ldr x16,[sp,#24]                                //
    ldr x20,[sp,#32]                                //

    add sp,sp,#40                                   //
    ret
    //----------------------------------------------- end paint_casita
