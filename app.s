	.include "graph_funs.s"
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

	movz w10,#0x0000,lsl 16     // color
    movk w10,#0x0000            // color

	mov x5, SCREEN_HEIGH
	mov x6, SCREEN_WIDTH
	mov x7, #100				// radio
	mul x7, x7, x7				// radio^2
	lsr x5,x5,1					// centro Y
	lsr x6,x6,1					// centro X

	bl background_paint			// Colorea el fondo completo del color en el reg. w10

	mov x2, SCREEN_HEIGH		//  \        
    mov x1, SCREEN_WIDTH		//   |=> Retorno a estados originales para uso por otros procedimientos
    mov x0,x23					//  /

	bl paint_circle				// colorea un circulo centro (x5,x6) de radio = x7, con el color en w11

	mov x2, SCREEN_HEIGH        //  \
    mov x1, SCREEN_WIDTH		//   |=> Retorno a estados originales para uso por otros procedimientos
    mov x0,x23					//  /



leo_gpio:
	movz x10,0xE100
	movk x10,0x05f5 ,lsl 16
loop_delay0:
	subs x10,x10,#1
	b.ne loop_delay0

	// Ejemplo de uso de gpios
	mov x21, GPIO_BASE

	// Atención: se utilizan registros w porque la documentación de broadcom
	// indica que los registros que estamos leyendo y escribiendo son de 32 bits
	

	// Setea gpios 0 - 9 como lectura
	str wzr, [x21, GPIO_GPFSEL0]

	// Lee el estado de los GPIO 0 - 31
	ldr w22, [x21,GPIO_GPLEV0]

	// And bit a bit mantiene el resultado del bit 2 en w10 (notar 0b... es binario)
	// al inmediato se lo refiere como "máscara" en este caso:
	// - Al hacer AND revela el estado del bit 2
	// - Al hacer OR "setea" el bit 2 en 1
	// - Al hacer AND con el complemento "limpia" el bit 2 (setea el bit 2 en 0)

	and w22,w22,0b00000001	// aisla el pin 1, que por alguna razon es la F en mi teclado, ingles US
	cbnz w22, paint_circ	// si se presiona la tecla el circulo cambia a negro

	movz x10,0xE100
	movk x10,0x05f5 ,lsl 16
loop_delay1:
	subs x10,x10,#1
	b.ne loop_delay1

	b leo_gpio
paint_circ:
	movz w11,0x0000
	bl paint_circle
	// si w11 es 0 entonces el GPIO 1 estaba liberado
	// de lo contrario será distinto de 0, (en este caso particular 2)
	// significando que el GPIO 1 fue presionado

	//---------------------------------------------------------------
	// Infinite Loop
InfLoop:
	b InfLoop
