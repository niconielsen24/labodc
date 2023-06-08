	//.include "graph_funs.s"
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

	bl paint_sky_day						//--- paint_sky_day y paint_sky_night son mutualmente exclusivas, una pisa a la otra

	bl paint_sun							//--- paint_sun anda junto con cualquiera de las 2, solo hay que llamarla despues (eventualmente una para la luna va a ser parecida) 

	bl fore_ground

	bl paint_casita

	// GPIO config set
	
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

	and w22,w22,0x00000001					// aisla el pin 1, que por alguna razon es la F en mi teclado, ingles US
	cbnz w22, paint_dia_noche				// si se presiona la tecla el circulo cambia a negro

//	movz x10,0xE100							// \
//	movk x10,0x05f5 ,lsl 16					//  \
//loop_delay1:								//   } Loop de delay
//	subs x10,x10,#1 						//  /
//	b.ne loop_delay1						// /
	b leo_gpio								// si no se detecta un cambio en w22 se regresa a leo_gpio

paint_dia_noche:

noche:
	cbnz x1, dia

	bl paint_sky_night
	bl paint_moon
	bl fore_ground
	bl paint_casita

	mov x1,1

	b leo_gpio

dia:

	bl paint_sky_day
	bl paint_sun
	bl fore_ground
	bl paint_casita

	mov x1,0

	b leo_gpio
	//---------------------------------------------------------------
	// Infinite Loop
InfLoop:
	b InfLoop
