    .model small
    .stack  100h

    .data
            enterfname  db 'Enter file name: $'
            error       db 'error $'
            equalMsg    db 'strings equal$'
            notEqualMsg db 'strings not equal$'
            filename    db 70 dup(0) ;t.t', 0 
            text1       db 80 dup('$')
            text2       db 80 dup('$')
            errorMsg    db 'Error', 10, 13, '$'
            doneMsg     db 'Done', 10, 13, '$'
            

            filehandle  dw ?

    .code
    newline macro            ;Print new line with code 10 13 characters
                             ;
            mov dl, 10       ;
            mov ah, 02h      ;
            int 21h          ;
                             ;
            mov dl, 13       ;c
            mov ah, 02h      ;
            int 21h          ;
    endm                     ;
    
    printError macro
       mov ah, 09h
       lea dx, errorMsg
       int 21h
    endm
    
    printResult macro
        cmp ax, 1
        jz stringsEqual
            mov ah, 09h
            lea dx, notEqualMsg
            int 21h
            jmp donePrintResult
       
        stringsEqual:
            mov ah, 09h
            lea dx, equalMsg
            int 21h
        donePrintResult:
    endm
    
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
            mov dx, offset filename
            mov ah, 09h
            int 21h
            
            
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

    readLines1 macro
        xor si, si
        startLines1:
            lea dx, [text1 + si]      ;where to store read characters
            mov ax, 3F00h             ;ms-dos read from file
            mov bx, [filehandle]      ;set filehandle to bx for reading
            mov cx, 1                 ;
            int 21h
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
            inc si
            cmp al, 0Ah               ;compare with 0a - newline
            jz doneLines1
        doneLines1:
        sub si, 2
        lea di, [text1 + si]
        mov [di], 0
    endm
    
    ;Reads a line into 
    readLines2 macro
        xor si, si
        startLines2:
            lea dx, [text2 + si]      ;where to store read characters
            mov ax, 3F00h             ;ms-dos read from file
            mov bx, [filehandle]      ;set filehandle to bx for reading
            mov cx, 1                 ;
            int 21h
            mov al, [text2 + si]      ;load read character into al
            inc si
            cmp al, 0Dh               ;compare it with 0d - newline
            jz readLines2_10          ;if its 0d check for 0a and read text2
            cmp al, 0                 ;if its 0 - EOF skip to done
            jz doneLines2
            jnz startLines2
        readLines2_10:
            lea dx, [text2 + si]      ;where to store read characters
            mov ax, 3F00h             ;ms-dos read from file
            mov bx, [filehandle]      ;set filehandle to bx for reading
            mov cx, 1                 ;
            int 21h
            mov al, [text2 + si]
            inc si
            cmp al, 0Ah               ;compare with 0a - newline
            jz doneLines2
        doneLines2:
        sub si, 2
        lea di, [text2 + si]
        mov [di], 0
    endm
    
    cleanText1 macro
        mov al, 5
        cleanLoop1:
            lea di, [text1 + al]
            mov [dx], '$'
            dec al
            jnz cleanLoop1 
    endm
    
    cleanText2 macro
        mov al, 5
        mov si, al
        cleanLoop2:
            lea di, [text2 + si]
            mov [di], '$'
            dec al
            jnz cleanLoop2 
    endm
    
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
            jc notEqual               ;jump out of loop if they are not the same, CF = 1
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
        
    
    main:

            mov ax, @data
            mov ds, ax
            
            fopen
            
            readLines1
            readLines2
            
            compareLines
            
            printResult
            
            ;Read argument
            ;mov dx, 81h
            ;mov bx, dx
            ;add bl, byte ptr [80h]
            ;mov byte ptr [bx], '$'
            
            ;mov dx, 40h
            ;mov ax, 02h ;09h prints string at dx
            ;int 21h
            
            ;mov si, 81h
            ;mov ah, 01h      ;read character
            ;int 21h
            
            ;Exit program
            mov ax, 4c00h
            int 21h
    end main