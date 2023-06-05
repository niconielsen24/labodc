	.equ SCREEN_WIDTH,   640
	.equ SCREEN_HEIGH,   480
    .equ BITS_PER_PIXEL, 32


    //----------------------------------------------- background paint
background_paint:
    sub sp,sp,#32

    mov x2, SCREEN_HEIGH         // Y Size
loop1:
	mov x1, SCREEN_WIDTH         // X Size
loop0:
	stur w10,[x0]				// Colorear el pixel N
	add x0,x0,4                 // Siguiente pixel
	sub x1,x1,1                 // Decrementar contador X
	cbnz x1,loop0               // Si no terminó la fila, salto
	sub x2,x2,1                 // Decrementar contador Y
	cbnz x2,loop1               // Si no es la última fila, salto
    
    add sp,sp,#32
    ret
    //----------------------------------------------- end background paint


    //----------------------------------------------- paint circle
paint_circle:
    sub sp,sp,#32

    mov x2, SCREEN_HEIGH         // Y Size
loop1_crc:
	mov x1, SCREEN_WIDTH         // X Size
loop0_crc:
    sub x8,x5,x2                // dist en Y al centro
    sub x9,x6,x1                // dist en X al centro
    mul x8,x8,x8                // a^2 -- distancia en Y al cuadrado
    mul x9,x9,x9                // b^2 -- distancia en X al cuadrado
    add x9,x9,x8                // a^2 + b^2 -- suma del cuadrado de las distancias
    cmp x9,x7                   // comparo distancias con radio
    b.hi cont_crc               // si a^2 + b^2 > r^2 => (a,b) ∉  a la imagen
	stur w11,[x0]				// Colorear el pixel N
cont_crc:
    add x0,x0,4                 // Siguiente pixel
	sub x1,x1,1                 // Decrementar contador X
	cbnz x1,loop0_crc           // Si no terminó la fila, salto
	sub x2,x2,1                 // Decrementar contador Y
	cbnz x2,loop1_crc           // Si no es la última fila, salto    

    add sp,sp,#32
    ret
    //----------------------------------------------- end paint circle

