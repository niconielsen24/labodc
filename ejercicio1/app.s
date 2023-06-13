	.include "object_graph_funs.s"
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

	bl paint_sky_day						// 	definicion en "object_graph_funs.s" pinta el fondo de celeste con algunas rayas
	bl paint_sun							//	definicion en "object_graph_funs.s" pinta el sol
	bl fore_ground							//	definicion en "object_graph_funs.s" pinta las lomas
	bl paint_casita							//	definicion en "object_graph_funs.s" pinta la casita

	// GPIO config set
	//

	mov x21, GPIO_BASE						// --self explanatory--

	str wzr, [x21, GPIO_GPFSEL0]			// Setea gpios 0 - 9 como lectura

	// GPIO read loop
	//

leo_gpio:									// si no se lee ningun input en el pin 1 se regresa a esta linea
	movz x10,0xE100							// \
	movk x10,0x05f5 ,lsl 16					//  \
loop_delay0:								// 	 }	Loop de delay
	subs x10,x10,#1							//  /
	b.ne loop_delay0						// /

	ldr w22, [x21,GPIO_GPLEV0]				// Lee el estado de los GPIO 0 - 31

	and w22,w22,0b00000100					// aisla el pin 1, que por alguna razon es la F en mi teclado, ingles US
	cbnz w22, paint_noche					// si se presiona la tecla el circulo cambia a negro

	b leo_gpio								// si no se detecta un cambio en w22 se regresa a leo_gpio

paint_noche:								//

	bl paint_sky_night						//	definicion en "object_graph_funs.s" pinta el fondo de naranja-oscuro con algunas rayas
	bl paint_moon							//	definicion en "object_graph_funs.s" pinta la luna
	bl fore_ground							//	definicion en "object_graph_funs.s" pinta las lomas
	bl paint_casita							//	definicion en "object_graph_funs.s" pinta la casita

noche_loop:
	ldr w22, [x21,GPIO_GPLEV0]				// Lee el estado de los GPIO 0 - 31
	and w22,w22,0b00000100					// aisla el pin 1, que por alguna razon es la F en mi teclado, ingles US
	cbnz w22, noche_loop					// si se presiona la tecla el circulo cambia a negro

	bl paint_sky_day						//	idem primer loop
	bl paint_sun							// 	idem primer loop
	bl fore_ground							//	idem primer loop
	bl paint_casita							//	idem primer loop

	b leo_gpio								// loop infinito a leo_gpio

	//---------------------------------------------------------------
	// Infinite Loop
InfLoop:
	b InfLoop
