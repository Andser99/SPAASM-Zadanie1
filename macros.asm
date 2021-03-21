    fopen macro
            ;Enter file name prompt
            ;jmp skip
            mov dx, offset enterfname
            mov ah, 09h
            int 21h
            
            mov di, offset filename
            mov ah, 01h
            
            
            char_read:
                int 21h
                
                cmp al, 0dh     ;check if enter was found
                je enter_found  ;continue with file opening
                
                ;save character to filename+1
                mov [di], al
                inc di
                
                jmp char_read
            
            enter_found:
                ;append \0 to file name
                mov [di], 0
                inc di
                mov [di], 24h
          
            ;skip:
                
            ;print file name
            ;mov dx, offset filename
            ;mov ah, 09h
            ;int 21h
            
            
            mov ah, 3Dh ; DOS open file
            mov al, 0h ; attribute
            mov dx, offset filename ; filename in ASCIIZ
            int 21h
            mov [filehandle], ax    ;move file handle to address of filehandle
            jnc successOpen         ;If no errors, continue, else print error
                printError
                mov ax, 4c00h
                int 21h
            successOpen:
    endm
    
    
    ;copies the content of text2 into text1
    copyT2toT1 macro
        lea si, text1
        lea di, text2
        dec si
        dec di
        
        ;copies chars until a $ is found
        copyCharsCycle:
            inc si
            inc di
            mov al, [di]
            mov [si], al
            cmp al, BYTE PTR '$'
            jnz copyCharsCycle
    endm
    
    ;compares text1 to text2, returns 1 on equal and 0 unequal
    compareLines macro
        lea si, text1            ;ds:si points to first string
        lea di, text2            ;ds:di points to second string
        dec si
        dec di
 
        compareChars:
            inc si                    ;next si character
            inc di                    ;next di character
            mov al, [si]              ;load al with next char from text1
            cmp [di], al              ;compare characters
            jnz notEqual               ;jump out of loop if they are not the same, CF = 1
            cmp al, 0
            jnc equal
            jmp compareChars
        
        equal:
            mov al, [di]
            cmp al, 0
            jnz compareChars
            mov ax, 1                 ;if strings are equal, set ax to 1
            jmp compareDone
        notEqual:
            mov ax, 0                 ;otherwise to 0
        compareDone:
    endm
    
    
    ;reads the first line, used just one, same as readLines2 proc
    ;text1 is used as a buffer to compare against new lines
    readLines1 macro
        xor si, si
        startLines1:
            lea dx, [text1 + si]      ;where to store read characters
            mov ax, 3F00h             ;ms-dos read from file
            mov bx, [filehandle]      ;set filehandle to bx for reading
            mov cx, 1                 ;read one character
            int 21h
            mov cx, ax                ;store read count into cx for further use
            mov al, [text1 + si]      ;load read character into al
            inc si
            cmp al, 0Dh               ;compare it with 0d - newline
            jz readLines1_10          ;if its 0d check for 0a and read text2
            cmp al, 0                 ;if its 0 - EOF skip to done
            jz doneLines1
            jnz startLines1
        readLines1_10:
            lea dx, [text1 + si]      ;where to store read characters
            mov ax, 3F00h             ;ms-dos read from file
            mov bx, [filehandle]      ;set filehandle to bx for reading
            mov cx, 1                 ;read just one character
            int 21h
            mov al, [text1 + si]      ;move read character to al from text1[si]
            cmp al, 0Ah               ;compare with 0a - newline
            jz doneLines1
        doneLines1:
        dec si
        lea di, [text1 + si]
        mov [di], 0
    endm
    
    printNewLine macro            ;Print new line with code 10 13 characters
                             ;
            mov dl, 10       ;
            mov ah, 02h      ;
            int 21h          ;
                             ;
            mov dl, 13       ;
            mov ah, 02h      ;
            int 21h          ;
    endm                     ;
    
    printError macro
       mov ah, 09h
       lea dx, errorMsg
       int 21h
    endm