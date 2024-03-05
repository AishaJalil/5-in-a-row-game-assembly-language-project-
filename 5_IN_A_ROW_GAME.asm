INCLUDE Irvine32.inc


.data


N DWORD 5
Board BYTE 5 DUP ('-')
RowSize = $-Board
          BYTE 5 DUP ('-')
          BYTE 5 DUP ('-')
          BYTE 5 DUP ('-')
          BYTE 5 DUP ('-')


prompt byte "----------------------------------------------------------------------------------------------------------",0
prompt2 byte "*********************************  WELCOME TO 5 IN A ROW GAME *******************************************",0
prompt3 byte "*********************************          GAME START         *******************************************",0
prompt4 byte "*********************************         SCORE BOARD         ********************************************",0
prompt5 byte "*********************************         PAUSE MENU          *******************************************",0
loginmsg byte "*********************************       LOGIN  OR  REGISTER       ***************************************",0
MenuStatement byte "Please enter the corresponding number to select an option from the menu: ", 0
MenuItem1 byte "1. Start Game", 0
MenuItem2 byte "2. Display Scoreboard", 0
MenuItem3 byte "3. Reset Score", 0
MenuItem4 byte "4. Exit", 0


pausemsg byte "You can pause your game at any instant by Entering 62.",0
selectmsg byte "Select an appropriate option.",0
quitmsg byte "3. Quit.",0
restartmsg byte "2. Restart Game.",0
resetmsg byte "1. Reset Score.",0
continuemsg byte "4. Continue game ", 0


WrongPass byte "You entered a wrong password", 0
presskey byte "Press any key to continue...",0
thankyou byte "*********************************       THANK YOU FOR PLAYING THE GAME!       ***************************************",0


Player DWORD 1
Player1 byte "Player 1, enter your character (X or O): ", 0
Player2 byte "Player 2, enter your character (X or O): ", 0
P2_piece byte "Player 2's character is: ", 0
Row_msg BYTE "Enter row number : ",0
Column_msg BYTE "Enter column number : ",0
Player1_wins byte "Player 1 wins!", 0
Player2_wins byte "Player 2 wins!", 0
_player byte "Player ", 0
PLayer1_piece byte ?
Player2_piece byte ?
InvalidInput byte "You entered an invalid input. Please enter again: ", 0
DrawMsg byte "It's a draw!", 0
Player1_score dword 0
Player2_score dword 0
display_score1 byte "Player 1 score: ", 0
display_score2 byte "Player 2 score: ", 0
rowIndex dword 0
colIndex dword 0


username_input DWORD 50 DUP (?)
password_input DWORD 50 DUP (?)
correct_username BYTE "admin", 0
correct_password BYTE "password", 0
login_prompt BYTE "Enter username: ", 0
password_prompt BYTE "Enter password: ", 0
wrong_login_msg BYTE "Incorrect username or password. Please try again.", 0
success BYTE "Successfully Logged in",0
username_file_path BYTE "username.txt", 0
password_file_path BYTE "password.txt", 0


BUFMAX=500
fileHandle   HANDLE ?                  ; Handle to the opened file
bytesRead    DWORD  ?                  ; Number of bytes read from the file
stringValue  BYTE   256 DUP(0) 
buffer       BYTE   BUFMAX DUP(0) ; Buffer to read file contents
;buffSize      DWORD  ? 
error        byte "Unable to open file",0
signup byte "Sign-Up : ",0
successSign byte "Successfully signed up",0


.code
main PROC 


mov eax, Blue + (lightCyan*16)      ;setting background and text color of console
call setTextColor
LL:
    mov edx, offset prompt
    call WriteString
    call Crlf
    mov edx, offset loginmsg    ;printing login message
    call WriteString
    call Crlf
    mov edx, offset prompt
    call WriteString
    call Crlf
    call crlf
call SignOrLog
  cmp eax, 0
    je wrong
        call clrscr
call Game
call AnyKeyToContinue
call clrscr
mov edx, offset thankyou    ;”thank you for playing” message
call writestring
jmp exitt


wrong:
JMP LL


exitt:
exit
main ENDP


Menu PROC
call clrscr
mov edx, offset prompt
call WriteString
call Crlf
mov edx, offset prompt2
call WriteString
call Crlf
mov edx, offset prompt
call WriteString
call Crlf
call crlf


mov edx, offset MenuStatement
call writestring
call crlf
mov edx, offset MenuItem1
call writestring
call crlf
mov edx, offset MenuItem2
call writestring
call crlf
mov edx, offset MenuItem3
call writestring
call crlf
mov edx, offset MenuItem4
call writestring
call crlf
call ReadInt
mov edx, offset prompt
call WriteString
call Crlf
ret
Menu ENDP


Game PROC


Start:
call Menu
cmp eax, 1
je next
cmp eax, 4
je exitt
cmp eax, 2
je Score
cmp eax, 3
jmp reset_score
mov edx, offset InvalidInput       ;invalid number entered
call writestring
jmp Start


Score:
call clrscr
mov edx, offset prompt
call WriteString
call Crlf
mov edx, offset prompt4
call WriteString
call Crlf
mov edx, offset prompt
call WriteString
call Crlf
call crlf
call ScoreBoard    ;display scoreboard
jmp Start


next:
call clrscr
mov edx, offset prompt
call WriteString
call Crlf
mov edx, offset prompt3
call WriteString
call Crlf
mov edx, offset prompt
call WriteString
call Crlf
call crlf 


mov edx, offset pausemsg
call writestring
call crlf


call GetPiece       ;set X and O for players
call crlf
push offset Board
call BuildBoard     ;print an empty board


main_game:
mov edx, offset prompt
call WriteString
call Crlf


push offset Board
call PrintBoard


push offset Board
call CheckifEmpty     ;checks for space on board
cmp eax, 0      ;if eax=0, then draw
je Draw


push OFFSET Board
push Player
call Read_Coord        ;takes row and column input


cmp eax, 1
je reset_score
cmp eax, 2
je next
cmp eax, 3
je exitt


call crlf




push OFFSET Board
call CheckMatch      ;checking for consecutive 5 characters on board


cmp eax,1   ;if 1, then there is winner
jne update   ;update player turn from 1 to 2, or 2 to 1


push Player
CALL Winner


push Player
call updateBoard    ;update scoreboard
call crlf
call AnyKeyToContinue
call clrscr
mov edx, offset prompt
call WriteString
call Crlf
jmp Start


update:
;update player
cmp Player, 1
je incTurn
dec Player 
jmp _nextt


incTurn:
inc Player


_nextt:
jmp main_game






Draw:
        mov edx,offset DrawMsg
        call WriteString
            call crlf
            call AnyKeyToContinue
            call clrscr
        jmp Start


reset_score:
mov Player1_score, 0
mov Player2_score, 0
jmp Score






exitt:
ret
Game ENDP






BuildBoard PROC 


push ebp
mov ebp, esp


mov ebx, [ebp+8]   ;board offset
mov edx, 0    ;row index
mov esi, 0     ;column index
mov ecx, 5    ;for 5 rows


L1:
mov eax, RowSize
mul edx
add ebx, eax
push ecx
mov ecx, 5


L2:
mov byte ptr [ebx+esi], '-'
inc esi
loop L2


pop ecx
inc edx
mov esi, 0
call crlf
loop L1


pop ebx
ret 4
BuildBoard ENDP


PrintBoard PROC 


push ebp
mov ebp, esp


mov ebx, [ebp+8]
mov edx, 0    ;row index
mov esi, 0     ;column index
mov ecx, 5    ;for 5 rows


L1:
mov eax, RowSize
mul edx
add ebx, eax      ;row offset
push ecx
mov ecx, 5


L2:
mov al, [ebx+esi]
call writeChar
mov al, ' '
call writeChar
inc esi
loop L2


pop ecx
inc edx
mov esi, 0
call crlf
loop L1


pop ebx
ret 4
PrintBoard ENDP


CheckifEmpty PROC 


enter 0, 0


mov ebx, [ebp+8]
mov edx, 0 ;row index
mov esi, 0 ;column index
mov ecx, 5 ;for 5 rows


L1:
mov eax, RowSize
mul edx
add ebx, eax
push ecx
mov ecx, 5


L2:
mov al, [ebx+esi]
cmp al, '-'
je available
inc esi
loop L2


pop ecx
inc edx
mov esi, 0
call crlf
loop L1


mov eax, 0 ;no space
jmp exitt


available:
mov eax, 1 ;there is space on board


exitt:
leave
ret 4
CheckifEmpty ENDP


GetPiece PROC
        enter 0, 0


        Input_p1:       ;getting player 1 input


                mov edx,offset Player1
                call WriteString
                call ReadChar
                call WriteChar
                call Crlf
                cmp al,'O'
                je p2_pieceX
                cmp al, 'X'
                je p2_pieceO
        mov eax, Red + (lightCyan*16)
        call setTextColor
                mov edx,offset InvalidInput                
                call WriteString
        call crlf
        mov eax, Blue + (lightCyan*16)
        call setTextColor
jmp input_p1


        p2_pieceX:
        mov Player1_piece, al       ;save player 1 piece
        mov Player2_piece, 'X'
        jmp exitt


        p2_pieceO:
        mov Player1_piece, al           ;save player 1 piece
        mov Player2_piece, 'O'




        exitt:
                mov edx, OFFSET P2_piece
                call writestring
                mov al, Player2_piece
                call writeChar
                leave
                ret


GetPiece ENDP


Read_coord PROC
    push ebp
    mov ebp, esp


  
    rowInput:
        mov eax,0
        mov edx ,offset _player
        call WriteString
        mov eax, [ebp+8] ; eax store player turn offset
        call WriteDec
        mov eax, ' '
        call writeChar
        mov edx ,offset Row_msg
        call WriteString
        call ReadInt
        cmp eax, 62
        JE pauseMenu1
        cmp eax,N
        jg wrongRow   ;wrong row number
        cmp eax,0
        jg checkColumn


        wrongRow:
            mov eax, Red + (lightCyan*16)
            call setTextColor
            mov edx,offset InvalidInput
            call WriteString
            call crlf
            mov eax, Blue + (lightCyan*16)
            call setTextColor


    jmp rowInput   ;take row input again for wrong row input


    checkColumn:
        dec eax
        mov ebx,RowSize
        mul ebx
        mov ebx, [ebp+12] 
        add ebx, eax ;ebx store row place in the board


        columnInput:
            mov edx ,offset Column_msg
            call writeString
            call readInt
            cmp eax, 62
            JE pauseMenu1
            cmp eax,N
            jg wrongColumn
            cmp eax,0
            jg valid


        wrongColumn:
            mov eax, Red + (lightCyan*16)
            call setTextColor
            mov edx,offset InvalidInput
            call WriteString
            call crlf
            mov eax, Blue + (lightCyan*16)
            call setTextColor
        jmp columnInput


    valid:
        dec eax
        mov edi, [ebp+8]
        cmp edi, 1
        je p1
        mov cl, Player2_piece
        cmp BYTE PTR[ebx+eax], '-'
        je setPiece
        mov edx, offset InvalidInput
        call WriteString
        jmp rowInput


        p1:
        mov cl, Player1_piece
        cmp BYTE PTR[ebx+eax], '-'
        je setPiece
        mov edx, offset InvalidInput
        call WriteString
        jmp rowInput


    setPiece:
        mov [ebx+eax],cl
        mov eax, 0 ; so that it doesn't call on options of pause menu in Game
        jmp exitt


    PauseMenu1:
        call PauseMenu
        cmp eax, 0
        je rowInput
    exitt:
        mov esp,ebp
        pop ebp
        ret 8
Read_coord ENDP


PauseMenu PROC
    push ebp
    mov ebp, esp
        call clrscr
        mov edx, offset prompt
    call WriteString
    call Crlf
        mov edx, offset prompt5
    call WriteString
    call Crlf
        mov edx, offset prompt
    call WriteString
    call Crlf
        call crlf


    mov edx, offset selectmsg
    call WriteString
    call Crlf
    mov edx, offset resetmsg
    call WriteString
    call Crlf
    mov edx, offset restartmsg
    call WriteString
    call Crlf
    mov edx, offset quitmsg
    call WriteString
    call Crlf
    mov edx, offset continuemsg
    call WriteString
    call Crlf


    L:
    call ReadInt
    cmp eax, 1
    je Reset
    cmp eax, 2
    je Restart
    cmp eax, 3
    je Quit
    cmp eax, 4
    je Continue
    jmp InvalidChoice


    Reset:
    mov eax, 1
    jmp exitt
   
    Restart:
    mov eax, 2
    jmp exitt
 
    Quit:
    mov eax, 3
    jmp exitt


    Continue:
    call clrscr
    push offset board
    call printBoard
    mov eax, 0
    jmp exitt


    InvalidChoice:
    mov eax, Red + (lightCyan*16)
    call setTextColor
    mov edx, offset InvalidInput
    call WriteString
    call crlf
    mov eax, Blue + (lightCyan*16)
    call setTextColor
    jmp L


    exitt:
    mov edx, offset prompt
    call WriteString
    call Crlf
    pop ebp
    ret
PauseMenu ENDP




Winner PROC


        enter 0, 0


        mov esi,[ebp+8] ; esi store player turn
        cmp esi, 1
        je player1Win
        mov edx, offset Player2_wins
        call writestring
        jmp skip


        player1Win:
                mov edx, offset Player1_wins
                call writestring


        skip:
                leave
                ret 4
Winner ENDP


Login PROC
   


    mov edx, offset login_prompt
    call writestring
    mov edx, offset username_input
    mov ecx, sizeof username_input
    call ReadString


    mov edx, offset password_prompt
    call writestring
    mov edx, offset password_input
    mov ecx, sizeof password_input
    call ReadString


    ; Check username and password from files
    call readUser  ; Add this line to read username from file
        mov  edx, OFFSET stringValue
    mov esi, offset username_input
    call CompareStrings 
    cmp eax, 0
    je WrongLogin


    call readPass  ; Add this line to read password from file
    mov  edx, OFFSET stringValue
    mov esi, offset password_input
    call CompareStrings
    cmp eax, 0
    je WrongLogin


    ; Successfully logged in
    mov eax, 1
    mov edx, OFFSET success
    call WriteString
    call crlf
    call crlf
    mov edx, offset prompt
    call WriteString
    call Crlf
    ret


    WrongLogin:
        mov eax, Red + (lightCyan*16)
        call setTextColor
        mov edx, offset wrong_login_msg
        call writestring
        call crlf
        mov eax, Blue + (lightCyan*16)
        call setTextColor
        ; Wrong info entered :(
        xor eax, eax
        ret
Login ENDP




readUser PROC
   ; Open the file
    mov  EDX, OFFSET username_file_path
    call OpenInputFile
    mov  fileHandle, eax
    mov  edx, OFFSET buffer
    mov  ecx, BUFMAX
    call ReadFromFile
  
    jc   show_error_message
    mov  bytesRead, eax


    ; Copy the string from buffer to stringValue
    mov  esi, OFFSET buffer    ; Source index
    mov  edi, OFFSET stringValue ; Destination index
    mov  ecx, bytesRead        ; Number of bytes to copy
    rep  movsb                 ; Repeat the move string operation byte by byte
    ; Close the file handle
    mov  eax, fileHandle
    call CloseFile


    jmp  exit_program


show_error_message:
call crlf
  mov edx, OFFSET error
  call WriteString


exit_program:
ret 
readUser ENDP


readPass PROC
   ; Open the file
    mov  EDX, OFFSET password_file_path
    call OpenInputFile


    mov  fileHandle, EAX
    mov  edx, OFFSET buffer
    mov  ecx, BUFMAX
    call ReadFromFile
 
    jc   show_error_message
    mov  bytesRead, eax


    ; Copy the string from buffer to stringValue
    mov  esi, OFFSET buffer    ; Source index
    mov  edi, OFFSET stringValue ; Destination index
    mov  ecx, bytesRead        ; Number of bytes to copy
    rep  movsb                 ; Repeat the move string operation byte by byte
    ; Close the file handle
    mov  eax, fileHandle
    call CloseFile


    jmp  exit_program


show_error_message:
call crlf
  
  mov eax, Red + (lightCyan*16)
  call setTextColor
  mov edx, OFFSET error
  call WriteString
  call crlf
  mov eax, Blue + (lightCyan*16)
  call setTextColor
exit_program:
ret 
readPass ENDP


CompareStrings PROC
    push ebx
    push ecx


    L1:
        movzx ebx, byte ptr [edx]
        movzx ecx, byte ptr [esi] 
        cmp ebx, ecx               
        jne NotEqual               


        cmp ebx, 0                 
        je Equal                  


        inc edx                   
        inc esi                    
        jmp L1                    


    NotEqual:
        xor eax, eax ; or mov eax, 0              
        jmp Done


    Equal:
        mov eax, 1                 


    Done:
        pop ecx
        pop ebx
        ret
CompareStrings ENDP


SignOrLog PROC
    ; Check if the username file exists
    mov EDX, OFFSET username_file_path
    call FileExists
    cmp eax, 1
    jne CreateFiles  ; If the username file doesn't exist, create files


    ; Check if the password file exists
    mov EDX, OFFSET password_file_path
    call FileExists
    cmp eax, 1
    jne CreateFiles  ; If the password file doesn't exist, create files
    ;jmp Login
    ;mov eax,1
    jmp Login
    ret
CreateFiles:
    mov edx, OFFSET signup
    call WriteString


    mov edx, OFFSET username_file_path
    call CreateOutputFile
    mov fileHandle, eax


    mov edx, OFFSET login_prompt
    call writestring


    mov edx, OFFSET buffer
    mov ecx, BUFMAX
    call ReadString
    mov username_input, eax


    mov eax, fileHandle
    mov ecx, LENGTHOF username_input
    mov edx, OFFSET buffer
    call WriteToFile
    call CloseFile


    ; Prompt user for password and write to file
    mov edx, OFFSET password_file_path
    call CreateOutputFile
    mov fileHandle, eax


    mov edx, OFFSET password_prompt
    call writestring


    mov edx, OFFSET buffer
    mov ecx, BUFMAX
    call ReadString
    mov password_input, eax


    mov eax, fileHandle
    mov ecx, LENGTHOF password_input
    mov edx, OFFSET buffer
    call WriteToFile
    call CloseFile


    mov edx, OFFSET successSign
    call WriteString
    mov eax, 1
    ret
SignOrLog ENDP


FileExists PROC USES ebx ecx esi edi
    ; Input: EDX points to the file path
    ; Output: EAX is set to 1 if the file exists, 0 otherwise




    ; Open the file in read mode
    mov eax, GENERIC_READ
    mov ebx, 0
    mov ecx, OPEN_EXISTING
    mov esi, FILE_ATTRIBUTE_NORMAL
    invoke CreateFile, edx, eax, ebx, 0, ecx, esi, 0


    ; Check if the file handle is valid
    cmp eax, INVALID_HANDLE_VALUE
    je  FileDoesNotExist


    ; File exists, close the file handle
    invoke CloseHandle, eax
    mov eax, 1
    jmp FileExistsDone


    FileDoesNotExist:
        mov eax, 0


    FileExistsDone:
        ret
FileExists ENDP




CheckMatch Proc


        push ebp
        mov ebp,esp


        mov eax, 0


        push [ebp+8]
        call RowCheck


        push [ebp+8]
        call ColumnCheck


        push [ebp+8]
        call DiagonalCheck


        cmp eax,1
        jne NoWinner


        push [ebp+8]
        call PrintBoard
    mov eax, 1
        jmp skip


        NoWinner:
                mov eax, 0


        skip:
                mov esp,ebp
                pop ebp
                ret 4
CheckMatch ENDP




 RowCheck PROC
    push ebp
    mov ebp, esp


        cmp eax,1
        je ExitCheck


    X_check:
        mov rowIndex, 0
        ; Outer loop for columns
        L3:
            mov ebx, [ebp + 8]
            cmp rowIndex, 5    ; Check if column index exceeds board size
            jge O_check       ; If so, proceed to O_check


            mov eax, RowSize  ; Move column index to eax
            mul rowIndex
            add ebx, eax
            mov ecx, 5        ; Set row index to 5
            mov esi, 0        ; Reset row index


            ; Inner loop for rows
            L4:
                mov al, [ebx+esi]
                cmp al, 'X'
                JNE nextCol_X
                inc esi
                cmp esi, ecx
                je Win_X
                jmp L4


            nextCol_X:
                inc rowIndex
                jmp L3


            Win_X:
                mov eax, 1
                jmp ExitCheck


            O_check:
                mov rowIndex, 0
                ; Outer loop for columns for 'O'
                L5:
                    mov ebx, [ebp + 8]
                    cmp rowIndex, 5    ; Check if column index exceeds board size
                    jge NoWin_O       ; If so, no win condition


                    mov eax, RowSize  ; Move column index to eax
                    mul rowIndex
                    add ebx, eax
                    mov ecx, 5        ; Set row index to 5
                    mov esi, 0        ; Reset row index


                    ; Inner loop for rows for 'O'
                    L6:
                        mov al, [ebx+esi]
                        cmp al, 'O'
                        JNE _nextRow_O
                        inc esi
                        cmp esi, ecx
                        je Win_O
                        jmp L6


                    _nextRow_O:
                        inc rowIndex
                        jmp L5


                Win_O:
                    mov eax, 1
                    jmp ExitCheck


                NoWin_O:
                    mov eax, 0
                    jmp ExitCheck


    ExitCheck:
        pop ebp
        ret 4
RowCheck ENDP




ColumnCheck PROC
    push ebp
    mov ebp, esp


        cmp eax,1
        je ExitCheck


    X_check:
        mov colIndex, 0
        ; Outer loop for columns
        L3:
            ;mov ebx, [ebp + 8]
            cmp colIndex, 5    ; Check if column index exceeds board size
            jge O_check        ; If so, proceed to O_check


            mov ecx, 5        ; Set row index to 5
            mov esi, 0        ; Reset row index


            ; Inner loop for rows for 'X'
            L4:
                                mov eax, RowSize  ; Move column index to eax
                                mul esi
                mov ebx, [ebp + 8]
                                add ebx, eax
                                mov edi, colIndex
                mov al, [ebx+edi]
                cmp al, 'X'
                JNE nextCol_X
                inc esi          ; Move to the next row
                cmp esi, ecx
                je Win_X         ; If the 'X' is found in all rows, it's a win
                jmp L4


            nextCol_X:
                inc colIndex
                jmp L3           ; Move to the next column


            Win_X:
                mov eax, 1
                jmp ExitCheck


            O_check:
                mov colIndex, 0
                ; Outer loop for columns for 'O'
                L5:
                    ;mov ebx, [ebp + 8]
                    cmp colIndex, 5    ; Check if column index exceeds board size
                    jge NoWin_O       ; If so, no win condition


                    mov ecx, 5        ; Set row index to 5
                    mov esi, 0        ; Reset row index


                    ; Inner loop for rows for 'O'
                    L6:
                                                mov eax, RowSize  ; Move column index to eax
                                                mul esi
                        mov ebx, [ebp + 8]
                                                add ebx, eax
                                                mov edi, colIndex
                        mov al, [ebx+edi]
                        cmp al, 'O'
                        JNE _nextCol_O
                        inc esi          ; Move to the next row
                        cmp esi, ecx
                        je Win_O         ; If the 'O' is found in all rows, it's a win
                        jmp L6


                    _nextCol_O:
                        inc colIndex
                        jmp L5


                Win_O:
                    mov eax, 1
                    jmp ExitCheck


                NoWin_O:
                    mov eax, 0
                    jmp ExitCheck


    ExitCheck:
        pop ebp
        ret 4
ColumnCheck ENDP


DiagonalCheck PROC
    push ebp
    mov ebp, esp


        cmp eax,1
        je ExitCheck


    ; Checking from top-left to bottom-right diagonal
    Check_X_LeftDiagonal:
        mov ecx, 5 
        mov eax, 0 
        mov esi, 0             ; Initialize the row index
        mov ecx, 5
        L1:
            mov ebx, [ebp + 8] 
            mov eax, RowSize 
            mul esi
            add ebx, eax 
            mov al, [ebx + esi] 


            cmp al, 'X' 
            jne Check_O_LeftDiagonal 


            inc esi 
            cmp ecx, 1
            JE WinDiagonal         
            loop L1
        
    ; Checking from top-left to bottom-right diagonal
    Check_O_LeftDiagonal:
        mov eax, 0 
        mov esi, 0 
        mov ecx, 5
        L2:
            mov ebx, [ebp + 8] 
            mov eax, RowSize 
            mul esi 
            add ebx, eax 
            mov al, [ebx + esi] 


            cmp al, 'O' 
            jne Check_X_RightDiagonal 


            inc esi 
            cmp ecx, 1
            JE WinDiagonal         
            loop L2
            
    ; Checking from top-right to bottom-left diagonal
    mov esi, 0 
    mov ecx, 5
    mov eax, 0
    Check_X_RightDiagonal:
        L3:
            mov ebx, [ebp + 8] ; 
            mov eax, RowSize 
            mul esi             
            add ebx, eax 
            mov edi, ecx
            sub edi, 1
            mov al, [ebx + edi] 


            cmp al, 'X' ; Check if it's 'X'
            jne Check_O_RightDiagonal          


            inc esi
            cmp ecx, 1
            JE WinDiagonal  
            loop L3


    Check_O_RightDiagonal:
        mov esi, 0 ; Initialize the row index
        mov ecx, 5
        mov eax, 0
        L4:
            mov ebx, [ebp + 8] ; 
            mov eax, RowSize 
            mul esi            
            add ebx, eax 
            mov edi, ecx
            sub edi, 1
            mov al, [ebx + edi] 


            cmp al, 'O'
            jne ExitCheck        


            inc esi
            cmp ecx, 1
            JE WinDiagonal  
            loop L4


    ; If the code reaches here, no win has been detected
    mov eax, 0
    jmp ExitCheck


    WinDiagonal:
        mov eax, 1
        jmp ExitCheck


    ExitCheck:
        pop ebp
        ret 4
DiagonalCheck ENDP


updateBoard PROC


push ebp
mov ebp, esp


mov eax, [ebp+8]
cmp eax, 1
je p1
inc Player2_score
jmp exitt


p1:
inc Player1_score


exitt:
pop ebp
ret 4
updateBoard endp


ScoreBoard PROC 


mov edx, offset display_score1
call writestring
mov eax, Player1_score
call writeDec
call crlf
mov edx, offset display_score2
call writestring
mov eax, Player2_score
call writeDec
call crlf
call AnyKeyToContinue
call clrscr


ret
ScoreBoard ENDP


AnyKeyToContinue PROC


mov edx, OFFSET presskey
call writestring
call readChar


ret
AnyKeyToContinue ENDP


END main
