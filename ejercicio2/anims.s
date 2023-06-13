    .include "graph_funs.s"

	.equ GPIO_BASE,    0x3f200000
	.equ GPIO_GPFSEL0, 0x00
	.equ GPIO_GPLEV0,  0x34

eye_move_up:
    sub sp,sp,#32


//    ldr w22, [x21,GPIO_GPLEV0]				// Lee el estado de los GPIO 0 - 31
//	and w24,w22,0b00000010					// Con esta mascara nos aseguramos de que W se mantenga presionada
											// para solo efectuar cambios si se mantiene
//	cbz w24, end_eye_up						// caso contrario regresamos a leo_gpio

	mov x8,50
	mul x7,x8,x8

	bl delay_loop_mov						// --delay--

	movz w10,#0x00ff,lsl 16					//
	movk w10,#0xffff						//

	bl background_paint						//

	add x5,x5,5								//		
	cmp x5,480								//
	b.ne cont_mv_up							//
	mov x5,0								//
cont_mv_up:									//

	movz w10,#0x0000,lsl 16					//
	movk w10,#0x0000						//

	bl paint_circle							//
//	b eye_move_up                           //
//end_eye_up:

    add sp,sp,#32
    ret

eye_move_l:

eye_move_l:
ldr w22, [x21,GPIO_GPLEV0]				// Lee el estado de los GPIO 0 - 31
	and w25,w22,0b00000100					// 

	cbz w25, end_eye_l						//

	mov x8,50								//
	mul x7,x8,x8							//

	bl delay_loop_mov						//

	movz w10,#0x00ff,lsl 16					//
	movk w10,#0xffff						//

	bl background_paint						//

	add x6,x6,5								//
	cmp x6,640								//
	b.ne cont_mv_l							//
	mov x6,0								//
cont_mv_l:									//

	movz w10,#0x0000,lsl 16					//
	movk w10,#0x0000						//

	bl paint_circle							//
	b eye_move_l								//
end_eye_l:

	add sp,sp,#32
    ret
