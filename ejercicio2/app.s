	.include "anims.s"
	.equ SCREEN_WIDTH,   640
	.equ SCREEN_HEIGH,   480
	.equ BITS_PER_PIXEL, 32

	.equ GPIO_BASE,    	0x3f200000
	.equ GPIO_GPFSEL0, 	0x00
	.equ GPIO_GPLEV0,  	0x34

	.equ MV_SPEED_FAST, 		0x0f0000
	.equ MV_SPEED_NORMAL,		0x4f0000
	.equ COLOR_BLACK,			0x0000 

	.globl main

main:
	// x0 contiene la direccion base del framebuffer
	mov x23, x0 // Guarda la dirección base del framebuffer en x20
	//---------------- CODE HERE ------------------------------------

	mov x15,10								// initial config Y for paint_ground
	mov x16,680								// initial config X for paint_ground

	mov x8,SCREEN_HEIGH						// initial config Y
	mov x9,SCREEN_WIDTH						// initial config X
	lsr x8,x8,1								// initial config Y
	lsr x9,x9,1								// initial config X

	bl paint_ground							// init paint ground

	// GPIO config set
	//

	mov x21, GPIO_BASE						// --self explanatory--

	str wzr, [x21, GPIO_GPFSEL0]			// Setea gpios 0 - 9 como lectura

	mov x1, MV_SPEED_NORMAL					// delay de animaciones

	// GPIO read loop
	//

leo_gpio:									// si no se lee ningun input en el pin 1 se regresa a esta linea
	mov x2,0xE100							// Seteo contador de ciclos para  
											// delay del loop que lee GPIO
	
	bl delay_loop_GPIO						// --delay--

	mov x7,0								// set move flag to not moving
	bl paint_ground

	ldr w22, [x21,GPIO_GPLEV0]				// Lee el estado de los GPIO 0 - 31

	and w24,w22,0b00011110					// 0b00000010 = w, 0b00000100 = A, 0b00001000 = S, 0b00010000 = D
	cbnz w24, move							// 

	and w28,w22,0b00100000					// 0b00100000 = [SPACE_BAR], aislamos el estado de [SPACE_BAR]
	cbnz w28, speed

	b leo_gpio								// si no se detecta un cambio en w22 se regresa a leo_gpio

	//---------------- ANIMATIONS ------------------------------------
move:
	mov x7,1								// set move flag to moving
	bl move_anim							// move animations
	b leo_gpio								// loop back to leo_gpio

speed:

	ldr w22, [x21,GPIO_GPLEV0]				// Lee el estado de los GPIO 0 - 31
	and w28,w22,0b00100000					// asegura que [SPACE_BAR] se mantiene presionada
	cbz w28,leo_gpio						// si [SPACE_BAR] no esta presionada volvemos a leo_gpio

	cmp x1,MV_SPEED_FAST					// \
	b.eq go_to_norm							//	\
	mov x1,MV_SPEED_FAST					// 	 \
	b leo_gpio								//	  } cambia entre las 2 velocidades para move_anim
go_to_norm:									//	 /
	mov x1,MV_SPEED_NORMAL					//	/
	b leo_gpio								// /
	
	//---------------------------------------------------------------
	// Infinite Loop
InfLoop:
	b InfLoop
