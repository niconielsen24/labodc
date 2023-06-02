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

	movz x10, 0x001b, lsl 16 	//color blue
	movk x10, 0x2F62, lsl 00	//color blue
	movk x11, 0xffff, lsl 16	//color white
	movk x11, 0xffff, lsl 00	//color white
	movz x19 ,0x0000, lsl 16	//color black

	mov x5 , SCREEN_HEIGH
	mov x6 , SCREEN_WIDTH
	mov x4 , #120					// radio circulo
	mov x18 , #0					// .............
	sub x18 , x4, #10				// radio menos 10, para poder hacer un borde
	lsr x5 , x5,1					// centro pantalla y
	lsr x6 , x6,1					// centro pantalla x

	mov x13, #0x0				// shift colorBlue
	mov x14, #0x1				// shift colorWhite
	mov x15, #0					// column counter
	mov x16, 40					// color-width-offset

	mov x2, SCREEN_HEIGH         // Y Size
loop1:
	mov x1, SCREEN_WIDTH         // X Size
loop0:
	sub x7,x1,x6				// distancia de pos x a centro x
	sub x8,x2,x5				// distancia de pos y a centro y
	mul x7,x7,x7				// dist cuad
	mul x8,x8,x8				// dist cuad
	add x7,x7,x8				// suma de distancias

	mul x20,x18,x18				// hipotenusa mas chica
	cmp x7,x20
	b.hs bighip
	stur w11,[x0]				// caso contrario (a,c) esta en la circunferencia, se colorea
	b continue
bighip:
	mul x9,x4,x4				// hipotenusa
	cmp x7,x9					// comparacion a^2+b^2 y c^2 --- distancia al centro
	b.hs not_circ				// si a^2+b^2 > c^2 => (a,b) no pertenece a la circunferencia, esta por fuera, no coloreamos
	stur w19,[x0]				// caso contrario (a,c) esta en la circunferencia, se colorea
	b continue
not_circ:
blanco:
	cbz w13,azul				// if shift colorBlue then goes to azul:
	stur w11,[x0]				// Colorear el pixel N
	b continue
azul:	
	cbz w14,blanco				// if shift colorWhite then goes to blanco:
	stur w10,[x0]  				// Colorear el pixel N
	b continue

continue:
	cmp w15, w16				// check if counter is at 40 rows
	b.ne cont_loop				// if counter != 16 then continue with the loop
	eor w13,w13,#1				// flip the register for shift colorBlue
	eor w14,w15,#1				// flip the register for shift colorwhite
	mov w15, #0					// reset counter
cont_loop:
	add x15,x15,1				// add 1 to the counter
	add x0,x0,4    // Siguiente pixel
	sub x1,x1,1    // Decrementar contador X
	cbnz x1,loop0  // Si no terminó la fila, salto
	sub x2,x2,1    // Decrementar contador Y
	cbnz x2,loop1  // Si no es la última fila, salto

	// Ejemplo de uso de gpios
	mov x21, GPIO_BASE

	// Atención: se utilizan registros w porque la documentación de broadcom
	// indica que los registros que estamos leyendo y escribiendo son de 32 bits

	// Setea gpios 0 - 9 como lectura
	str wzr, [x21, GPIO_GPFSEL0]

	// Lee el estado de los GPIO 0 - 31
	ldr w22, [x21, GPIO_GPLEV0]

	// And bit a bit mantiene el resultado del bit 2 en w10 (notar 0b... es binario)
	// al inmediato se lo refiere como "máscara" en este caso:
	// - Al hacer AND revela el estado del bit 2
	// - Al hacer OR "setea" el bit 2 en 1
	// - Al hacer AND con el complemento "limpia" el bit 2 (setea el bit 2 en 0)

	and w22,w22,0b00000010


	// si w11 es 0 entonces el GPIO 1 estaba liberado
	// de lo contrario será distinto de 0, (en este caso particular 2)
	// significando que el GPIO 1 fue presionado

	//---------------------------------------------------------------
	// Infinite Loop
InfLoop:
	b InfLoop
