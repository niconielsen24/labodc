    .include "graph_funs.s"

	.equ GPIO_BASE,    0x3f200000
	.equ GPIO_GPFSEL0, 0x00
	.equ GPIO_GPLEV0,  0x34

	.equ SCREEN_WIDTH,   640
	.equ SCREEN_HEIGH,   480
    .equ BITS_PER_PIXEL, 32
	
	.equ COLOR_BLACK,	0x0000
	.equ SHIP_COLOR_G,	0xf111
	.equ SHIP_COLOR_W0,	0x00ff
	.equ SHIP_COLOR_W1,	0xffff
	.equ SHIP_HEIGHT,	60

	//----------------------------------------------- funct index
	//
	// >>>> ln 28	: paint_starship
	//
	// >>>> ln 96	: paint_starship_black
	//
	// >>>> ln 161	: paint_ground
	//	
	// >>>> ln 285	: move_anim
	//

	//----------------------------------------------- paint_starship
	//
	// En base a paint_line_hr se pintan 2 triangulos para hacer de "navecita"
	//
	//
paint_starship:
	sub sp,sp,#56							// mem alloc
	
	str lr,[sp]								//	push to sp
	str x10,[sp,#8]							//	push to sp color
	str x15,[sp,#16]						//	push to sp Y for paint_line_hr
	str x16,[sp,#24]						//	push to sp X start for paint_line_hr
	str x20,[sp,#32]						//	push to sp X end for paint_line_hr
	str x11,[sp,#40]						//	push to sp ship counter
	str x12,[sp,#48]						//	push to sp ship section counter

	mov x10,SHIP_COLOR_G					//	color verde para la base de la navecita
	mov x11,SHIP_HEIGHT						//	cargamos el largo total de la navecita al contador 
	lsr x11,x11,1							//	la base de la navecita es solo la mitad
	mov x15,x8								//	pasamos x8 a x15 para no cambiar las coordenadas originales
	add x15,x15,x11							//	sumamos la mitad de la altura a x15 para que esta se empiece a dibujar de la mitad para abajo
	mov x16,x9								//	pasamos x9 como punto inicial para ambos lados de la navecita
	mov x20,x9								//	pasamos x9 como punto inicial para ambos lados de la navecita

ship_base_loop:								//
	cbz x11, ship_base_loop_end				// 	while x11 != 0
	bl paint_line_hr						// 	pintamos una linea
	add x20,x20,1							// 	sumamos un pixel a x20 X end
	sub x16,x16,1							//	restamos un pixel a x16 X start
	add x15,x15,1							//	sumamos un pixel a la altura
	sub x11,x11,1							//	restamos unidad al contador de altura
	b ship_base_loop						//	loop back
ship_base_loop_end:							//	end

	movz w10,SHIP_COLOR_W0,lsl 16			//	color blanco para la cabina de la navecita
	movk w10,SHIP_COLOR_W1					//	color blanco para la cabina de la navecita
	mov x11,SHIP_HEIGHT						//	reiniciamos el contador
	mov x12,5								//	contador de lineas para la cabina
	mov x15,x8								//	idem loop base
	mov x16,x9								//	idem loop base
	mov x20,x9								//	idem loop base

ship_main_loop:								//
	cbz x11, ship_main_loop_end				//	while x11 != 0
	bl paint_line_hr						//	pintamos una linea
	cbnz x12,cont_ship_main_loop			//	si x12 no es 0, no agrandamos la linea a pintar
	add x20,x20,1							//	--
	sub x16,x16,1							//	--
	mov x12,5								//	reinciamos el contador de lineas
cont_ship_main_loop:						//	--
	add x15,x15,1							//	sumamos un pixel a la altura
	sub x11,x11,1							//	restamos unidad al contador de altura
	sub x12,x12,1							//	restamos unidad al contador de lineas
	b ship_main_loop						//	loop back
ship_main_loop_end:							//	end

	ldr lr,[sp]								//	pop from sp	
	ldr x10,[sp,#8]							//	pop from sp
	ldr x15,[sp,#16]						//	pop from sp
	ldr x16,[sp,#24]						//	pop from sp
	ldr x20,[sp,#32]						//	pop from sp
	ldr x11,[sp,#40]						//	pop from sp
	ldr x12,[sp,#48]						//	pop from sp

	add sp,sp,#56							// free mem
	ret
	//----------------------------------------------- end paint_starship

	//----------------------------------------------- paint_starship_black
	//
	// Idem paint_starship solo que todo se pinta de negro (se usa para eliminar algunos bugs de ghosting, no completamente)
	//
	//
paint_starship_black:
	sub sp,sp,#56							// mem alloc
	
	str lr,[sp]								//	push to sp
	str x10,[sp,#8]							//	push to sp color
	str x15,[sp,#16]						//	push to sp Y for paint_line_hr
	str x16,[sp,#24]						//	push to sp X start for paint_line_hr
	str x20,[sp,#32]						//	push to sp X end for paint_line_hr
	str x11,[sp,#40]						//	push to sp ship counter
	str x12,[sp,#48]						//	push to sp ship section counter

	mov x10,COLOR_BLACK						//	---
	lsr x11,x11,1							//	---
	mov x15,x8								//	--- 
	add x15,x15,x11							//	---
	mov x16,x9								//	---
	mov x20,x9								//	---

black_base_loop:							//	---
	cbz x11, black_base_loop_end			//	---
	bl paint_line_hr						//	--- 	
	add x20,x20,1							//	--- 	 
	sub x16,x16,1							//	---	 
	add x15,x15,1							//	---	
	sub x11,x11,1							//	---	
	b black_base_loop						//	---	
black_base_loop_end:						//	---	

	mov x11,SHIP_HEIGHT						//	---	
	mov x12,5								//	---	
	mov x15,x8								//	---	
	mov x16,x9								//	---	
	mov x20,x9								//	---	

black_main_loop:							//	---
	cbz x11, black_main_loop_end			//	---
	bl paint_line_hr						//	---	
	cbnz x12,cont_black_main_loop			//	---	
	add x20,x20,1							//	---	
	sub x16,x16,1							//	---	
	mov x12,5								//	---	
cont_black_main_loop:						//	---	
	add x15,x15,1							//	---	
	sub x11,x11,1							//	---	
	sub x12,x12,1							//	---	
	b black_main_loop						//	---	
black_main_loop_end:						//	---	

	ldr lr,[sp]								//	pop from sp	
	ldr x10,[sp,#8]							//	pop from sp
	ldr x15,[sp,#16]						//	pop from sp
	ldr x16,[sp,#24]						//	pop from sp
	ldr x20,[sp,#32]						//	pop from sp
	ldr x11,[sp,#40]						//	pop from sp
	ldr x12,[sp,#48]						//	pop from sp

	add sp,sp,#56							// free mem
	ret
	//----------------------------------------------- end paint_starship_black

	//----------------------------------------------- paint_ground
paint_ground:
	sub sp,sp,#40							// mem alloc
	
	str lr,[sp]								// push to sp
	str x3,[sp,#8]							// push to sp
	str x2,[sp,#16]							// push to sp
	str x10,[sp,#24]						// push to sp
	str x11,[sp,#32]						// push to sp

	mov w10,COLOR_BLACK						//	---

	//----------------------------------------------- background section
	//
	// solo se pinta si se esta en movimiento, de otra forma la navecita deja rastro (igual hay problemas de ghosting)
	// no se pinta siempre porque tarda mucho tiempo
	//
	cbz x7,do_not_paint_bkg					//	x7 es el flag para saber si se esta o no en movimiento
	bl background_paint						//	si se esta en movimiento se pinta el fondo entero de negro
do_not_paint_bkg:							//	

	//----------------------------------------------- current Y height check
	//
	//	chequeamos si x15(Y) llego a la altura original para la segunda linea mas uno (51)
	//	asi tratamos dar una sensacion de "infinidad" al pasar de los px
	//	chequeamos en 51 y no en 50 ya que sino el contador se reinicia antes de que se puedan borrar los px viejos
	// 	quedan lineas estaticas, se puede comprobar cambiendo el valor 51 por 50
	//
	cmp x15,51								//	comparamos x15 con 51 (una unidad mas abajo que la 2 linea en su posicion original)
	b.lt not_null_Y							//	si no es 51 no hacemos nada
	mov x15,10								//	si es 51 la reseteamos
not_null_Y:									//	---

	mov x3,x15								//	pasamos x15 a x3 para no cambiar las coordenadas originales
	mov x2,x16								//	pasamos x16 a x2 para no cambiar las coordenadas originales

	//----------------------------------------------- erase last row of PXs
	//
	//	si no se esta en movimiento para evitar tener que pintar el fondo entero
	//	se pintan del color del fondo los px en la posicion anterior a la actual
	//	a menos que estemos en la posicion orignal, en cual caso no hay px a borrar
	//

	cbnz x7, not_erase_last_px				//	si se esta en movimiento este loop no hace nada
	cmp x15,10								//	si se esta en la altura original de inicio tampoco hace nada
	b.eq not_erase_last_px					//	---
	sub x15,x15,1							//	restamos un pixel a la altura ctual, es decir un pixel mas arriba
ground_loop_0_D:								//	---
	cmp x15,480								//	comparamos x15, con 480, la ultima fila
	b.ge end_ground_loop_0_D					//	si estamos en la ulima fila (la de mas abajo) termina el ciclo
	cmp x16,#20								//	comparamos x16 con 20, la columna mas cercana al borde izquierdo que queremos pintar
	b.ne ground_loop_0_D_cont				//	si no lo estamos continuamos
	mov x16,x2								//	si lo estamos reiniciamos x16
	add x15,x15,40							//	y pasamos a la siguiente fila 40 px mas abajo
ground_loop_0_D_cont:						//	---
	bl set_pixel							//	pintamos el px donde nos encontramos
	sub x16,x16,10							//	distanciamos los px a pintar por 10 px
	b ground_loop_0_D						//	loop back
end_ground_loop_0_D:							//	end

not_erase_last_px:							// <<<< aca vamos directamente si estamos en movimiento


	//----------------------------------------------- color change for PXs
	//
	// usamos el mismo blanco de la navecita para los px del fondo
	//
	//
	movz w10,SHIP_COLOR_W0,lsl 16			//	color
	movk w10,SHIP_COLOR_W1					//	color

	mov x15,x3								//	reiniciamos x15
	mov x16,x2								//	reiniciamos x16

	//----------------------------------------------- PXs paint section
	//
	//	Idem a erase last row of PXs, solo que se ejecuta en todos los ciclos y con color distinto al fondo
	//
	//
ground_loop_0:								//	---
	cmp x15,480								//	---
	b.ge end_ground_loop_0					//	---
	cmp x16,#20								//	---
	b.ne ground_loop_0_cont					//	---
	mov x16,x2								//	---
	add x15,x15,40							//	---
ground_loop_0_cont:							//	---
	bl set_pixel							//	---
	sub x16,x16,10							//	---
	b ground_loop_0							//	---
end_ground_loop_0:							//	---

	//----------------------------------------------- starship and delays
	//
	//	La navecita se pinta siempre en esta subrutina
	//	el fondo tiene su propia velocidad, pero si se esta en movimiento se avanza a la misma velocidad que la navecita
	//	en cualquiera de sus 2 velocidades
	//

	bl paint_starship						//	pintamos la navecita por encima de todos los px

	cbz x7,not_moving						//	si no nos estamos moviendo el fondo se mueve mas lento
	bl delay_loop_mov						//	si nos estamos moviendo el fondo se mueve a la velocidad de la nave
	b end_ground							//	saltamos el delay por defecto de paint_ground
not_moving:									//	---

	bl delay_loop_ground					//	delay por defecto de paint_ground

end_ground:									//	end subroutine

	add x15,x3,1							//	restamos una unidad a la altura original para futuras llamadas
	mov x16,x2								//	reiniciamos x16 a su valor original

	ldr x3,[sp,#8]							//	pop from sp
	ldr x2,[sp,#16]							//	pop from sp
	ldr x10,[sp,#24]						//	pop from sp
	ldr x11,[sp,#32]						//	pop from sp
	ldr lr,[sp]								//	pop from sp
	
	add sp,sp,#40							// mem free
	ret
	//----------------------------------------------- end paint_ground


	//----------------------------------------------- move_anim
move_anim:
	sub sp,sp,#64							// mem alloc
	
	str lr,[sp]								// push to sp
	str x10,[sp,#8]							// push to sp color
	str x21,[sp,#16]						// push to sp GPIO_BASE
	str x22,[sp,#24]						// push to sp reg para leer pins
	str x24,[sp,#32]						// push to sp pin 2, letra W
	str x25,[sp,#40]						// push to sp pin 3, letra A
	str x26,[sp,#48]						// push to sp pin 4, letra S
	str x27,[sp,#56]						// push to sp pin 5, letra D

	mov x21, GPIO_BASE						// --self explanatory--
	str wzr, [x21, GPIO_GPFSEL0]			// Setea gpios 0 - 9 como lectura

	//----------------------------------------------- move loop
	//
	// selecciona hacia a donde moverse dependiendo de la tecla presionada
	//
move_loop:

	//bl delay_loop_mov						// --delay--

	ldr w22, [x21,GPIO_GPLEV0]				// Lee el estado de los GPIO 0 - 31
	and w24,w22,0b00000010					// Con esta mascara nos aseguramos de que W se mantenga presionada
	cbnz w24, move_up_anim					// para solo efectuar cambios si se mantiene
	
	and w25,w22,0b00000100					// 0b00000100 = A, aislamos el estado de A
	cbnz w25, move_l_anim					// si se presiona A se mueve hacia la izquierda

	and w26,w22,0b00001000					// 0b00001000 = S, aislamos el estado de S
	cbnz w26, move_dwn_anim					// si se presiona S se mueve hacia la izquierda

	and w27,w22,0b00010000					// 0b00010000 = D, aislamos el estado de D
	cbnz w27, move_r_anim					// si se presiona D se mueve hacia la izquierda

	b end_mv								// caso contrario regresamos a main

	//----------------------------------------------- move up loop section
move_up_anim:

	bl paint_starship_black					//	para evitar ghosting

	sub x8,x8,5								// 	restamos 5 unidades a Y para mover la navecita
	cmp x8,0								//	si x8 es la primer fila  vamos al otro lado, la ultima fila
	b.ne cont_mv_up							//	sino continuamos
	mov x8,480								//	---
cont_mv_up:									//	---

	bl paint_ground							//	pintamos el fondo

	b move_loop								// regresamos al loop de move selec

	//----------------------------------------------- move up left section
move_l_anim:

	bl paint_starship_black					//	idem move_up_anim

	sub x9,x9,5								// 	restamos 5 unidades a X para mover la navecita
	cmp x9,640								//	si x9 es la ultima columna  vamos al otro lado, la primer columna
	b.ne cont_mv_l							//	sino continuamos
	mov x9,0								//	---
cont_mv_l:									//	---

	bl paint_ground							//	pintamos fondo

	b move_loop								//	idem move_up_anim

	//----------------------------------------------- move down loop section
move_dwn_anim:

	bl paint_starship_black					// 	idem move_up_anim

	add x8,x8,5								// 	inverso move_up_anim
	cmp x8,480								//	inverso move_up_anim 
	b.ne cont_mv_dwn						//	inverso move_up_anim
	mov x8,0								//	---
cont_mv_dwn:								//	---

	bl paint_ground							// 	idem move_up_anim

	b move_loop								// 	idem move_up_anim

	//----------------------------------------------- move right loop section
move_r_anim:

	bl paint_starship_black					// 	idem move_l_anim

	add x9,x9,5								//	inverso move_l_anim
	cmp x9,0								//	inverso move_l_anim
	b.ne cont_mv_r							//	inverso move_l_anim
	mov x6,640								//	---
cont_mv_r:									//	---

	bl paint_ground							// idem move_l_anim

	b move_loop								// idem move_l_anim

	//----------------------------------------------- end move loop
end_mv:										//

	ldr lr,[sp]								//	pop from sp
	ldr x10,[sp,#8]							//	pop from sp
	ldr x21,[sp,#16]						//	pop from sp
	ldr x22,[sp,#24]						//	pop from sp
	ldr x24,[sp,#32]						//	pop from sp
	ldr x25,[sp,#40]						//	pop from sp
	ldr x26,[sp,#48]						//	pop from sp
	ldr x27,[sp,#56]						//	pop from sp

	add sp,sp,#64							// mem free

	ret										//
	//----------------------------------------------- end move_anim
