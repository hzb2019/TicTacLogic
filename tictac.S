.data

    //
    // The Game description data structure
    //
    .equ    game_rows, 0
    .equ    game_cols, 4
    .equ    game_array, 8 
    .equ    game_size, 16

    //
    // The Game cell data structure
    // This is the contents of a location in the array
    //
    .equ    cell_expected, 0
    .equ    cell_actual, 4
    .equ    cell_size, 8

    //
    // Text for drawing the game
    //
    double_space: .asciz "  "
    single_space: .asciz " "
    print_num:    .asciz "  %d"
    print_num_gr: .asciz " %d"
    print_row_num:.asciz "  %d "
    print_char:   .asciz "  %c"
    newline:      .asciz "\n"

.text

.global create_game

//
// Create the game abstract data type
// void *create_game(int rows, int cols)
//
create_game:
	  stp x29, x30, [sp, #-16]!
	  stp x19, x20, [sp, #-16]!
	  stp x21, x22, [sp, #-16]!

    mov w19, w0       // rows
    mov w20, w1       // cols

    mov w0, #1
    mov w1, #game_size
    bl calloc         // allocate

    //
    // Set the data structure initial values
    //  
    str w19,[x0,#game_rows]
    str w20,[x0,#game_cols]

    mov x21, x0       // game pointer

    //
    // Allocate the game array
    //
    mul w0, w19, w20  // row * cols
    mov w1, #cell_size  // Cell size
    bl calloc

    str x0, [x21, #game_array]

    mov x0, x21


create_game_done:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    
    
.global destroy_game
//
// void destroy_game(void *game)
// Destroy the game, freeing all memory
//
destroy_game:
	  stp x29, x30, [sp, #-16]!
  	stp x19, x20, [sp, #-16]!

    mov x19, x0

    ldr x0, [x0, #game_array]   // free the Game array data
    bl free
  
    mov x0, x19                 // free the Game structure
    bl free

    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    
    
.global get_rows

//
// Get the number of rows in the game
// int get_rows(void *game)
//
get_rows:
    ldr w0, [x0, #game_rows]
    ret

.global get_cols

//
// Get the number of columns in the game
// int get_cols(void *game)
//
get_cols:
    ldr w0, [x0, #game_cols]
    ret

.global display_game

//
// Display the game
//
display_game:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    mov w19, #1     // w19 is row index
    mov w20, #0     // w20 is col index, set to 0 so display_game_top works
    
    ldr w21, [x0, #game_rows]   // w21 is amount of rows
    ldr w22, [x0, #game_cols]   // w22 is amount of columns

    mov x23, x0                 // x23 is the game pointer
    

display_game_top:
    cmp w20, w22
    bgt display_game_top_end

    cmp w20, #0                 // check if first iteration
    beq display_game_top_first

    cmp w20, #10
    bge display_game_alt_top

    ldr x0, =print_num          // print the number at the top of the game
    b display_game_alt_top_end

display_game_alt_top:
    ldr x0, =print_num_gr

display_game_alt_top_end:
    mov w1, w20
    bl printf

    add w20, w20, #1            // increment column value, continue loop
    b display_game_top

display_game_top_first:
    ldr x0, =double_space
    bl printf
    ldr x0, =double_space
    bl printf               // print quadruple space
    add w20, w20, #1        
    b display_game_top

display_game_top_end:
    mov w19, #1
    mov w20, #1

    ldr x0, =newline
    bl printf

display_game_loop_check:
    cmp w19, w21
    ble display_game_new_row_check

    b display_game_done
    
display_game_new_row_check:
    cmp w20, #1
    bne display_game_loop

    ldr x0, =print_row_num
    mov w1, w19
    bl printf

display_game_loop:

    mov x0, x23
    mov w1, w19
    mov w2, w20
    bl game_index

    add x0, x0, #cell_actual
    ldr w1, [x0]
    ldr x0, =print_char
    bl printf
    
    add w20, w20, #1        // increment column count

    cmp w20, w22
    ble display_game_loop_check

display_game_row_end:
    mov w20, #1
    add w19, w19, #1
    
    ldr x0, =newline
    bl printf

    b display_game_loop_check

display_game_done:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret


.global set_cell_actual

//
// int set_cell_actual(void *game, int row, int col, char ch);
// Returns: 1 if the answer value is correct
//
set_cell_actual:
	  stp x29, x30, [sp, #-16]!
	  stp x19, x20, [sp, #-16]!

    mov w19, w3                     // save ch in w19
    bl game_index

    ldr w4, [x0, #cell_expected]    // load expected into w4

    str w19, [x0, #cell_actual]     // save ch into game

    mov w0, #1                      // returns 1 if actual == expected 

    cmp w4, w19                     // compare actual to expected
    beq set_cell_actual_done

    mov w0, #0                      // returns 0 if actual != expected 
    
set_cell_actual_done:
	  ldp x19, x20, [sp], #16
	  ldp x29, x30, [sp], #16
    ret

.global set_cell_expected

//
// void set_cell_expected(void *game, int row, int col, char ch);
//
set_cell_expected:
	  stp x29, x30, [sp, #-16]!
	  stp x19, x20, [sp, #-16]!
    
    mov w19, w3                     // save ch in w19
    bl game_index

    str w19, [x0, #cell_expected]   // save ch into game

	  ldp x19, x20, [sp], #16
	  ldp x29, x30, [sp], #16
    ret



.global game_win

//
// int game_win(void *game)
// Returns true when the game is done/won
//
game_win:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    mov w19, #1     // w19 is row index
    mov w20, #1     // w20 is col index
    
    ldr w21, [x0, #game_rows]   // w21 is amount of rows
    ldr w22, [x0, #game_cols]   // w22 is amount of columns

    mov x23, x0     // x23 is game pointer

// while(row <= number of rows)
game_win_loop_check:
    cmp w19, w21
    ble game_win_loop

    mov w0, #1        // loop finished without any failures, return 1
    b game_win_done

game_win_loop:
    mov x0, x23
    mov w1, w19
    mov w2, w20
    bl game_index         // game_index(game, current_row, current_col)

    ldr w1, [x0, #cell_expected]    // w1 = expected
    ldr w2, [x0, #cell_actual]      // w2 = actual

    cmp w1, w2
    bne game_win_false              // if(expected != actual) return 0

    add w20, w20, #1      // current_col++
    cmp w20, w22          // if(current_col > number of columns)
    bgt game_win_inc_row  // { break }

    b game_win_loop       // while(1)

game_win_false:
    mov w0, #0            // return 0
    b game_win_done

game_win_inc_row:
    add w19, w19, #1      // current_row ++
    mov w20, #1           // current_col = 1
    b game_win_loop_check // go to loop condition
    
game_win_done:
    ldp x19, x20, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x23, x24, [sp], #16
	  ldp x29, x30, [sp], #16
    ret


    

.global game_index
//
// int *game_index(void *game, int row, int col)
// Get the address of a row and column in the cells
//   
game_index:
    sub w1, w1, #1              // row -= 1
    sub w2, w2, #1              // col -= 1

    ldr w3, [x0, #game_cols]    // get the number of columns
    mul w1, w1, w3              // row *= number of columns
    add w1, w1, w2              // row = row * number of columns + column

    mov w2, #cell_size          // w2 = cell_size
    mul w1, w1, w2              // row = size(cell) * (row * columns + c)

    ldr x4, [x0, #game_array]   // x0 = game_array

    add x4, x4, w1, uxtw

    mov x0, x4
	  ret
	

