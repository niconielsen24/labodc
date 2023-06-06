    .include "graph_funs.s"

    //----------------------------------------------- paint_sun 
paint_sun:
    sub sp,sp,#32
    
    str lr,[sp]
    str x5,[sp,#8]
    str x6,[sp,#16]
    str x7,[sp,#24]

    
    add sp,sp,#32
    ret
