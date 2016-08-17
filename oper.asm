
.486

IF1 
INCLUDE macros.txt	
ENDIF 

cod segment para public 'code' use16
public DRAWBOARD
public GET_VALID_INPUT
public PRINT_GOODBYE
public UPDATE_MATRIX
public UPDATE_SCORE
public EVALUATE_BOARD
public CLEAR_SCREEN
public GET_PLAY_AGAIN_DECISION
public PRINT_SCORE
public matrix	
public gameOver
public scorePlayerOne	
public scorePlayerTwo


CELL_OCCUPIED_MESSAGE	db	0DH,0AH,"Cell already occupied!",0DH,0AH,"$"	
EQUAL_GAME_MESSAGE		db	0DH,0AH,"Draw Game!",0DH,0AH,"$"
PLAYER1_WON_MESSAGE		db	0DH,0AH,"Player 1 won!",0DH,0AH,"$"
PLAYER2_WON_MESSAGE		db	0DH,0AH,"Player 2 won!",0DH,0AH,"$"
GOODBYE_MESSAGE			db	0DH,0AH,"Game Ended!",0DH,0AH,"$"
VALID_INPUT_MESSAGE		db	0DH,0AH,"Cell number entered: $"
INVALID_INPUT_MESSAGE	db	0DH,0AH,"Incorrect Input $"
GET_INPUT_MESSAGE		db	0DH,0AH,"Which square? [1-9]: $ "
PLAY_AGAIN_MESSAGE		db	0DH,0AH,"Do you want to play again?[Y/N]: $"
HORIZONTAL_DIVIDER		db 	0DH,0AH,"-|-|-",0DH,0AH,"$"
LINEFEED				db	0DH,0AH,"$" 
HORIZONTAL_MATRIX_LINE  db  ?,"L",?,"L",?,"$"						; L because 'L' + '0' = '|'		
SCORE_MESSAGE_PLAYER_ONE			dd  "rocS",":1P ",0DH,0AH,"$"
SCORE_MESSAGE_PLAYER_TWO			dd  "rocS",":2P ",0DH,0AH,"$"
matrix		db	'N','N','N','N','N','N','N','N','N','$'				; N becuase 'N'+'0' is ~ 
player		db	0
gameOver	db	0
nrMoves		db	0
scorePlayerOne	dd	0
scorePlayerTwo	dd	0
one	dd	1


		Assume cs:cod
		

PRINT_SCORE proc near												; procedure for printing score for the two players

	mov edx, scorePlayerOne											; put player one's score in edx
	add edx,'0'														; add 0 for printing
	mov SCORE_MESSAGE_PLAYER_ONE +8, edx 							; add the value into the score message							
	mov cx,13														; initialize counter for printing message characters
	mov bx,0														; initialize index for printing message characters
	
	Print_Player1_Score_Label:	
			MOV EDX, SCORE_MESSAGE_PLAYER_ONE+ BX 					; print individual characters
			mov AH,02												
			INT 21H													; Display character 		
			add bx,1												; increment index for printing next character 
	loop Print_Player1_Score_Label									
	
	mov edx, scorePlayerTwo											; put player two's score in edx
	add edx,'0'														; add 0 for printing
	mov SCORE_MESSAGE_PLAYER_TWO +8,  edx
	mov cx,13														; initialize counter for printing message characters
	mov bx,0														; initialize index for printing message characters
	
	Print_Player2_Score_Label:	
			MOV EDX, SCORE_MESSAGE_PLAYER_TWO+ BX 					; print individual characters
			mov AH,02										
			INT 21H;												; Display character 		
			add bx,1											    ; increment inner counter
	loop Print_Player2_Score_Label
	
	ret																; return from procedure

 PRINT_SCORE endp
 
DRAWBOARD	proc	near											; procedure for drawing the game board
	
	Print_Message LINEFEED											;| print a new line for readability			
														;|

	mov bx,0 														; initialize index for outer loop with zero

	Outer_Loop_Label:
	
	mov dl, matrix + bx 											;|
	mov HORIZONTAL_MATRIX_LINE, dl									;|
	mov dl, matrix + bx+1											;|
	mov HORIZONTAL_MATRIX_LINE+2,dl									;| initialize the HO_MA_LI with values from matrix for printing 
	mov dl, matrix + bx+2											;| purposes
	mov HORIZONTAL_MATRIX_LINE+4,dl									;|
	
		mov cx,5 													; set counter to 5 ( nr of characters in HO_MA_LI)
		push bx 													; save value of outer loop
		mov bx,0; 													; initialize idnex for inner loop with zero
		
		Inner_Loop_Label:
		
			MOV DH,0
			MOV DL, HORIZONTAL_MATRIX_LINE+BX 						; get HO_MA_Li char into DL
			
			cmp dl,1												;| check if value is 1. in that case, jump to  
			je Display_X_Label										;| Display_X_Label and print "X"
			
			add DL,'0'												; If it got to this point, the value is 0, and we add '0' to DL 
			jmp Already_Displayed_Label								; for printing purposes
			
			Display_X_Label:					
			add DL,'W' 												; Add 'W' to dl in order to display X not 1
			
			Already_Displayed_Label:
			
			mov AH,02
			INT 21H													; Display value in dl. In this case, 0 or | will be displayed
			add bx,1												; increment inner counter
			
		loop Inner_Loop_Label
		
		pop bx														; pop value for index for outer loop
		add bx,3													; increment index with 3- as we need to get the next 3 values from
																	; matrix array
		
		Print_Message HORIZONTAL_DIVIDER							;| display HORIZONTAL_DIVIDER
		
		
	cmp bx,9														; check if we printed all the matrix. If not, print another line,
	jb Outer_Loop_Label												; if yes, exit procedure
		
	ret																; return from procedure
	
DRAWBOARD endp


UPDATE_SCORE proc near												; procedure to update the score after a game has finished
	;Input: bx = which player won. It can either be 0 or 1

	finit															; initialize the math coprocessor
	cmp bx,0														; check if player 2 won
	je Player_Two_Won_Label
	
	fld scorePlayerOne												; if code reaches this point, it means player 1 won. 
	fld one															;|
	fadd															;| increment player one score
	fstp scorePlayerOne 											;|
	
	ret																; return from procedure

	Player_Two_Won_Label:											; if code reaches this point, it means player 2 won. 
	fld scorePlayerTwo
	fld one															;|
	fadd															;| increment player 2 score
	fstp scorePlayerTwo 											;|
	
	ret																; return from procedure
	
UPDATE_SCORE endp
 
 
GET_PLAY_AGAIN_DECISION proc near  									; procedure to check if players want to play again
	;Output: ax = decision to play again or not
	
	Get_Decision_Label:
	
	Print_Message PLAY_AGAIN_MESSAGE								; display the PLAY_AGAIN_MESSAGE 
	
	MOV	AH,08														; Function to read a char from keyboard which represents
	INT 21H 														; the play again decision. It is loaded in DL
	
	cmp al,'Y'     													;| check if the input is 'Y'
	je Yes_Answer_Label												;|
	
	cmp al,'N'     													;| check if the input is 'N'
	je No_Answer_Label												;|
	
	Print_Message INVALID_INPUT_MESSAGE								;| If it got to this point, it means that the user entered
																	;| something else than 'Y' or 'N', so it is invalid
																	;| display  INVALID_INPUT_MESSAGE
																	
	jmp Get_Decision_Label											;| get the decision again
	
	Yes_Answer_Label:
	push ax															
	call RESET_VALUES												; reset the game, in order to for the player 
	pop ax
	
	No_Answer_Label:
	MOV DH,0 														
	MOV DL,AL 														; Copy the char in AL to DL to output it
	mov AH,02														; Display input character
	INT 21H															
	
	mov ax, dx														; put the character in ax for output
	push ax															; push ax value

	Print_Message LINEFEED											;| print a new line for readability			
																	;|

	pop ax															; pop ax value
	
	ret																; return from procedure
	
GET_PLAY_AGAIN_DECISION endp

RESET_VALUES proc near												; procedure for reseting values if the player wants to start another game
	
	mov nrMoves,0													;|
	mov gameOver,0													;|	reset values for different parameters
	mov player,0													;|

	mov cx,9														; initialize counter for reseting matrix array, 9 is the length of the array
	mov ax, 0;
	mov bx,0;
		Reset_Label:
			MOV matrix+BX, 'N' 										; Put 'N' in DH. We use 'N' becuase 'N'+'0' is ~ 
			inc bx													; increment the index for the loop
		loop Reset_Label
		
	ret																; return from procedure
	
RESET_VALUES endp


EVALUATE_BOARD proc near											; procedure for evaluating the board 
	
	inc nrMoves														; increment the number of moves
	
	cmp nrMoves,9													; see if 9 moves have been introduced
	jl Not_Maximum_Moves_Reached_Label								; if yes, game over
	mov gameOver,1													
	ret																;return from procedure
	
	Not_Maximum_Moves_Reached_Label:								; if code reached this level it means that 9 moves haven't been introduced 
	
	call CHECK_IF_PLAYER_WON										; call a procedure to see if either of the players won the game
	
	ret																; return from reducere
	
EVALUATE_BOARD endp


CHECK_IF_PLAYER_WON proc near										; procedure to see if either of the players won the game
	
	mov al,1 														;| check row,column,diagonal to see if player 1 won
	call CHECK_ROW_FOR_WIN											;|
	call CHECK_COLUMN_FOR_WIN										;|	
	call CHECK_DIAGONAL_FOR_WIN										;|
	
	cmp gameOver,1													; check if game over
	jne Player_One_Didnt_Win_Label									
	
	mov bx,1														; mark that player 1 won by putting 1 in bx
	call UPDATE_SCORE												; call UPDATE_SCORE procedure 
	ret																; return from reducere
	
	Player_One_Didnt_Win_Label:										; if code got here, it means that player 1 didn't win the game
	
	mov al,0														;| check row,column,diagonal to see if player 0 won
	call CHECK_ROW_FOR_WIN											;|
	call CHECK_COLUMN_FOR_WIN										;|
	call CHECK_DIAGONAL_FOR_WIN										;|
	
	cmp gameOver,1													; check if game over
	jne Player_Two_Didnt_Win_Label	
	
	mov bx,0														; mark that player 0 won by putting 0 in bx
	call UPDATE_SCORE												; call UPDATE_SCORE procedure 
	
	Player_Two_Didnt_Win_Label:

	ret																;return from procedure
	
CHECK_IF_PLAYER_WON endp
	

CHECK_ROW_FOR_WIN proc near											; procedure to see if a player managed to complete a full row
; Input bx = which player to check for

		mov cx,3													; initialize counter for loop
		mov bx, 0													; initialize index for loop
		
		Row_Loop_Label:
			MOV DL, matrix+BX 										;|
			cmp dl, al												;|see if the first position in line is 0/1
			jne Next_Row_Label										;|if it isn't, line is not complete and it jumps to the next line
			
			MOV DL, matrix+BX+1										;|
			cmp dl,al												;|see if the second position in line is 0/1
			jne Next_Row_Label										;|if it isn't, line is not complete and it jumps to the next line
			
			MOV DL, matrix+BX+2										;|
			cmp dl,al												;|see if the third position in line is 0/1
			jne Next_Row_Label										;|if it isn't, line is not complete and it jumps to the next line
			
			mov gameOver,1											; if code got to this point, it means that the line is complete and the game is over
			ret														; return from procedure
			
			Next_Row_Label:
			add bx,3												; check the next line of the matrix
			
		loop Row_Loop_Label											; repeat above procedure for next line
	
	ret																; return from procedure
	
CHECK_ROW_FOR_WIN endp
	

CHECK_COLUMN_FOR_WIN proc near										; procedure to see if a player managed to complete a full column
; Input bx = which player to check for

		mov cx,3													; initialize counter for loop
		mov bx, 0													; initialize index for loop
		
		Column_Loop_Label:
		
			MOV DL, matrix+BX 										;|
			cmp dl, al												;|see if the first position in column is 0/1
			jne Next_Column_Label									;|if it isn't, column is not complete and it jumps to the next column
			
			MOV DL, matrix+BX+3 									;|
			cmp dl,al												;|see if the second position in column is 0/1
			jne Next_Column_Label									;|if it isn't, column is not complete and it jumps to the next column
			
			MOV DL, matrix+BX+6										;|
			cmp dl,al												;|see if the third position in column is 0/1
			jne Next_Column_Label									;|if it isn't, column is not complete and it jumps to the next column
			
			
			mov gameOver,1											; if code got to this point, it means that the column is complete and the game is over
			ret														; return from procedure
			
			Next_Column_Label:
			add bx,1												; check the next column of the matrix
			
		loop Column_Loop_Label

	ret																; return from procedure
	
CHECK_COLUMN_FOR_WIN endp
	

CHECK_DIAGONAL_FOR_WIN proc near									; procedure to see if a player managed to complete a full diagonal
; Input bx = which player to check for

		MOV DL, matrix 											;|
		cmp dl, al												;|see if the first position in primary diagonal is 0/1
		jne No_Match_Primary_Diagonal_Label						;|if it isn't, diagonal is not complete and it jumps to check other diagonal
			
		MOV DL, matrix+4  										;|
		cmp dl,al												;|see if the second position in primary diagonal is 0/1
		jne No_Match_Primary_Diagonal_Label						;|if it isn't, diagonal is not complete and it jumps to check other diagonal
			
		MOV DL, matrix+8 									    ;|
		cmp dl,al												;|see if the third position in primary diagonal is 0/1
		jne No_Match_Primary_Diagonal_Label						;|if it isn't, diagonal is not complete and it jumps to check other diagonal
			
		jmp End_Game_Label										;if code reached this point, the game has ended and we jump to the End_Game_Label
	
		No_Match_Primary_Diagonal_Label:						; we check the secondary diagonal for win situation

		MOV DL, matrix+2 								  		;|
		cmp dl, al												;|see if the first position in secondary diagonal is 0/1
		jne No_Match_Secondary_Diagonal_Label					;|if it isn't, diagonal is not complete and we jump to the end of the procedure
			
		MOV DL, matrix+4  								  		;|
		cmp dl,al												;|see if the second position in secondary diagonal is 0/1
		jne No_Match_Secondary_Diagonal_Label					;|if it isn't, diagonal is not complete and we jump to the end of the procedure
			
		MOV DL, matrix+6  								  		;|
		cmp dl,al												;|see if the third position in secondary diagonal is 0/1
		jne No_Match_Secondary_Diagonal_Label					;|if it isn't, diagonal is not complete and we jump to the end of the procedure

	
		End_Game_Label:											; if code got here, it means that either we have a full primary diagonal or seconday diagonal
			
		mov gameOver,1											; mark game over
		
		No_Match_Secondary_Diagonal_Label:						; no game over situation
			
		ret														; return from procedure
		
CHECK_DIAGONAL_FOR_WIN endp



UPDATE_MATRIX proc near											; procedure for updating the matrix array
;input bx = A number in 1-9 interval

	xor player,1												; alternate order of players. One turn we introduce 0, one turn we introduce 1										
	mov dl,player												; move the value in player in DL
	
	cmp matrix+bx,'N'											;| check if the cell is occupied
	je Cell_Not_Occupied_Label									;| if no, jump to that label
	
	dec nrMoves													; if code reaches this point, the cell has been occupied. nrMoves has already been incremented in a previous procedure
																; so we have to decrement it, as the move introduced is not a valid one
	
	Print_Message  CELL_OCCUPIED_MESSAGE							;|display CELL_OCCUPIED_MESSAGE

	
	xor player,1												; reset the value in player, as it is the same player's turn again, even though he introduced an incorret input
	
	ret															; return from procedure
	
	Cell_Not_Occupied_Label:									; if code got to this point that means that the cell introduced is unoccupied so far
	mov matrix+bx,dl											; update the matrix array with the value in DL
	
	ret															; return from procedure
	
UPDATE_MATRIX endp

GET_VALID_INPUT proc near										; procedure for getting a valid input from the user for the cell selected
;output: position in bx

	push ax 													; save ax content
	
	Get_Valid_Input_Label:
	
	Print_Message GET_INPUT_MESSAGE								;| display the GET_INPUT_MESSAGE  
												
	MOV	AH,08													; Function to read a char from keyboard repersenting the selected cell
	INT 21H 													; The char saved in al	
	
	sub al,'1'    												;| check if the input is a number in 1-9 interval
	cmp al,'9'-'1'												;|
	jbe isNumber	
	
	
	Print_Message INVALID_INPUT_MESSAGE							;| If the code got to this point it means that the input was invalid
																;| display the INVALID_INPUT_MESSAGE
															
	
	jmp Get_Valid_Input_Label 									; reask user for a valid input
	
	isNumber:
	
	Print_Message VALID_INPUT_MESSAGE							;| If the code got to this point it means that the input was valid
																;| display the VALID_INPUT_MESSAGE
													
	
	add al,'1' 													; Restore character in al for printing
	
	MOV DH,0 													;| 
	MOV DL,AL 													;| Display input character
	mov AH,02													;|
	INT 21H;
	
	sub al,'1'													;|
	mov bh,0													;| put the valid output in bx
	mov bl,al													;|
	
	pop ax														; restore ax content
	
	ret															; return from procedure

GET_VALID_INPUT endp


CLEAR_SCREEN proc near											; clear screen procedure
		
		push ax													; save the value in ax
		
		mov	ax,0000h											;|
		int	10h													;| call BIOS function for cleaning the screen
		
		pop ax													; restore the value in ax
		
	ret															; return from procedure

CLEAR_SCREEN endp

PRINT_GOODBYE proc near											;procedure to print goodbye message depending on the outcome of the game
	
	cmp nrMoves,9												;see how many moves have been performed
	jne Not_Equal_Label
	
	Print_Message EQUAL_GAME_MESSAGE 							;| Display EQUAL_GAME_MESSAGE 
	ret															; return from procedure
	
	Not_Equal_Label:											; if code reached this level, it means that the game was not a draw
	
	cmp player,1												; see if player 1 won or not
	je Player_1_Won_Label
			
	Print_Message PLAYER2_WON_MESSAGE							;| Display PLAYER2_WON_MESSAGE 
	ret															; return from procedure
	
	Player_1_Won_Label:																		
	
	Print_Message PLAYER1_WON_MESSAGE							;| Display PLAYER1_WON_MESSAGE 

	Print_Message GOODBYE_MESSAGE								;| Display GOODBYE_MESSAGE  
	

	ret															; return from procedure

PRINT_GOODBYE endp

cod     	ends

       	end 


