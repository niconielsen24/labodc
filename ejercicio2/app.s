	.include "graph_funs.s"
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

	// flai

	movz w10,#0x00ff,lsl 16
	movk w10,#0xffff

	bl background_paint

	movz w10,#0x0000,lsl 16
	movk w10,#0x0000

	mov x5,240
	mov x6,320
	mov x8,100
	mul x7,x8,x8

	bl paint_circle

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

	and w22,w22,0b00000010					// 0b00000010 = w, 0b00000100 = a, 0b00001000 = s, 0b00010000 = d, 0b00100000 = [SPACE_BAR]
	cbnz w22, paint_animation				// si se presiona la tecla el circulo cambia a negro

	b leo_gpio								// si no se detecta un cambio en w22 se regresa a leo_gpio

paint_animation:

	ldr w22, [x21,GPIO_GPLEV0]				// Lee el estado de los GPIO 0 - 31
	and w22,w22,0b00000010					// 0b00000010 = w, 0b00000100 = a, 0b00001000 = s, 0b00010000 = d, 0b00100000 = [SPACE_BAR]

	cbz w22, leo_gpio

	movz x9,0x0000							// \
	movk x9,0x00ff ,lsl 16					//  \
loop_delay_w:								// 	 }	Loop de delay
	subs x9,x9,#1							//  /
	b.ne loop_delay_w						// /


	movz w10,#0x00ff,lsl 16
	movk w10,#0xffff

	bl paint_circle

	add x5,x5,5
	sub x8,x8,1
	mul x7,x8,x8

	movz w10,#0x0000,lsl 16
	movk w10,#0x0000

	bl paint_circle

	b paint_animation

	//---------------------------------------------------------------
	// Infinite Loop
InfLoop:
	b InfLoop
