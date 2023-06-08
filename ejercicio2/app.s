	.include "graph_funs.s"
	.include "anims.s"
	.equ SCREEN_WIDTH,   640
	.equ SCREEN_HEIGH,   480
	.equ BITS_PER_PIXEL, 32

	.equ GPIO_BASE,    0x3f200000
	.equ GPIO_GPFSEL0, 0x00
	.equ GPIO_GPLEV0,  0x34

	.globl main

main:
	// x0 contiene la direccion base del framebuffer
	mov x23, x0 // Guarda la dirección base del framebuffer en x20
	//---------------- CODE HERE ------------------------------------

	movz w10,#0x00ff,lsl 16					// Color blanco para el fondo
	movk w10,#0xffff						//

	bl background_paint						// colorea el fondo completo

	movz w10,#0x0000,lsl 16					// color negro para el circulo
	movk w10,#0x0000						//

	mov x5,240								// posicion inicial circulo Y
	mov x6,320								// posicion inicial circulo X
	mov x8,50								// Radio
	mul x7,x8,x8							// R^2

	bl paint_circle							// circulo inicial

	// GPIO config set
	//

	mov x21, GPIO_BASE						// --self explanatory--

	str wzr, [x21, GPIO_GPFSEL0]			// Setea gpios 0 - 9 como lectura

	movz x1,0x00ff ,lsl 16					// Seteo contador de ciclos para  
	movk x1,0x0000							// delay de animaciones // speed_increase reduce este numero

	// GPIO read loop
	//

leo_gpio:									// si no se lee ningun input en el pin 1 se regresa a esta linea
	movz x2,0xE100							// Seteo contador de ciclos para  
	movk x2,0x05f5 ,lsl 16					// delay del loop que lee GPIO
	
	bl delay_loop_GPIO						// --delay--

	ldr w22, [x21,GPIO_GPLEV0]				// Lee el estado de los GPIO 0 - 31

	and w24,w22,0b00000010					// 0b00000010 = w, aislamos el estado de W
	cbnz w24, move_up						// si se presiona W se mueve hacia arriba

	and w25,w22,0b00000100					// 0b00000100 = A, aislamos el estado de A
	cbnz w25, move_l						// si se presiona A se mueve hacia la izquierda

	and w26,w22,0b00001000					// 0b00001000 = S, aislamos el estado de S
	cbnz w26, move_dwn						// si se presiona S se mueve hacia abajo

	and w27,w22,0b00010000					// 0b00010000 = D, aislamos el estado de D
	cbnz w27, move_r						// si se presiona S se mueve hacia la izquierda

	and w28,w22,0b00100000					// 0b00100000 = [SPACE_BAR], aislamos el estado de [SPACE_BAR]
	cbnz w28, speed_increase

	b leo_gpio								// si no se detecta un cambio en w22 se regresa a leo_gpio

	//---------------- ANIMATIONS ------------------------------------

move_up:
	ldr w22, [x21,GPIO_GPLEV0]				// Lee el estado de los GPIO 0 - 31
	and w24,w22,0b00000010					// Con esta mascara nos aseguramos de que W se mantenga presionada
											// para solo efectuar cambios si se mantiene
	cbz w24, leo_gpio						// caso contrario regresamos a leo_gpio

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
	b move_up								//

move_l:										//
	ldr w22, [x21,GPIO_GPLEV0]				// Lee el estado de los GPIO 0 - 31
	and w25,w22,0b00000100					// 

	cbz w25, leo_gpio						//

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
	b move_l								//

move_r:										//
	ldr w22, [x21,GPIO_GPLEV0]				// Lee el estado de los GPIO 0 - 31
	and w27,w22,0b00010000					// 

	cbz w27, leo_gpio						//

	mov x8,50								//
	mul x7,x8,x8							//

	bl delay_loop_mov						//

	movz w10,#0x00ff,lsl 16					//
	movk w10,#0xffff						//

	bl background_paint						//

	sub x6,x6,5								//
	cmp x6,0								//
	b.ne cont_mv_r							//
	mov x6,640								//
cont_mv_r:									//

	movz w10,#0x0000,lsl 16					//
	movk w10,#0x0000						//

	bl paint_circle							//
	b move_r								//

move_dwn:									//
	ldr w22, [x21,GPIO_GPLEV0]				// Lee el estado de los GPIO 0 - 31
	and w26,w22,0b00001000					// 

	cbz w26, leo_gpio						//

	mov x8,50								//
	mul x7,x8,x8							//

	bl delay_loop_mov						//

	movz w10,#0x00ff,lsl 16					//
	movk w10,#0xffff						//

	bl background_paint						//

	sub x5,x5,5								//
	cmp x5,0
	b.ne cont_mv_dwn
	mov x5,480
cont_mv_dwn:


	movz w10,#0x0000,lsl 16					//
	movk w10,#0x0000						//

	bl paint_circle							//
	b move_dwn								//

speed_increase:								//
	ldr w22, [x21,GPIO_GPLEV0]				// Lee el estado de los GPIO 0 - 31
	and w28,w22,0b00100000					// 

	cbz w28, leo_gpio						//

	sub x1,x1,1								//

	b speed_increase						//
	//---------------------------------------------------------------
	// Infinite Loop
InfLoop:
	b InfLoop
