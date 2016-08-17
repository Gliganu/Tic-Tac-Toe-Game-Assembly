
.486

cod segment para public 'code' use16
extrn 	DRAWBOARD:near
extrn 	PRINT_WELCOME:near
extrn 	GET_VALID_INPUT:near
extrn 	PRINT_GOODBYE:near
extrn	UPDATE_MATRIX:near
extrn	EVALUATE_BOARD:near
extrn 	GET_PLAY_AGAIN_DECISION:near
extrn 	PRINT_SCORE:near
extrn   CLEAR_SCREEN:near
extrn 	UPDATE_SCORE:near
extrn 	matrix		: byte
extrn 	gameOver	: byte




		Assume cs:cod, ds:cod, es:cod, ss:nothing
		org	100h
main:		jmp	entry

entry:		
	
		
		Play_Again_Label:
		
		call CLEAR_SCREEN 		; clearing screen
		
		call PRINT_SCORE 		; printing score
		call DRAWBOARD 			; drawing board
		
		Move_Label: 
	
		call GET_VALID_INPUT  	; get valid position to place X/0

		call CLEAR_SCREEN 		; clearing screen
		
		call UPDATE_MATRIX 		; updating the matrix based on the user input
		call DRAWBOARD			; drawing board
		call EVALUATE_BOARD		; check if the game has ended or not
		
		cmp gameOver,1		
		je End_Label			; if game is over, go to the End_Label
		
		jmp Move_Label			;if not over, get the next move from  the player
		 
		End_Label:
		
		call PRINT_GOODBYE		; print GoodBye message
		call PRINT_SCORE		; print the current score
		call GET_PLAY_AGAIN_DECISION	; check if the users want to play another game
		
		cmp ax,'Y'				
		je Play_Again_Label		; if the user has entered 'Y' then play again, if not, return to OS
		
		mov	ax,4c00h
		int	21h					;return to OS


	

cod	ends

        end 	main


