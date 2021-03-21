    INCLUDE macros.asm
    
    .model small
    .stack  100h

    .data
            enterfname  db 'Enter file name: $'
            error       db 'error $'
            equalMsg    db 'strings equal', 10, 13, '$'
            notEqualMsg db 'strings not equal', 10, 13, '$'
            filename    db 15 dup(0)
            text1       db 255 dup('$')         ;Limits the line length to 252 chars + newline + $
            text2       db 255 dup('$')
            errorMsg    db 'Error', 10, 13, '$'
            doneMsg     db 'Done', 10, 13, '$'
            printedC    dw 1, 1
            printedMax  db 0    ;0 means printedC will never be equal, so no paging
            helpMsg     db 'Program that loads a given file by name and prints each line', 10, 13
            helpMsg2    db 'as long as its not a repeat of the previous one', 10, 13
            helpMsg3    db 'Available launch arguments: ', 10, 13
            helpMsg4    db '-p   -    waits for input when the console is filled', 10, 13
            helpMsg5    db '-h   -    prints the help menu', 10, 13, '$'
            

            filehandle  dw ?

    .code

    
    ;prints the result based on ax register
    ;equal on 1, distinct on 0
    ;also preserves ax after it finishes
    printResult PROC
        cmp ax, 1
        push ax
        jz screenAvailable ;if strings are equal, just skip
            mov ah, 09h
            lea dx, text1
            int 21h
            printNewLine
            ;mov ah, 09h            ;debug message if unequal
            ;lea dx, notEqualMsg
            ;int 21h
            jmp donePrintResult
       
            stringsEqual:           ;debug messages if equal, redundant label
            ;mov ah, 09h
            ;lea dx, equalMsg
            ;int 21h
        donePrintResult:
        
        ;compare the amount of printed lines for paging
        lea di, printedC            ;load printed lines
        mov bl, [di]                
        inc bl                      ;increase printed lines
        mov [di], bl                ;save printed lines
        lea si, printedMax          ;load maximum of printed lines
        mov al, [si]
        cmp bl, al                  ;compare with maximum
        jnz screenAvailable         ;if max <> printed, skip to end
            mov [di], 1             ;else reset counter and wait for user input
            call waitForUserInput
        screenAvailable:
        pop ax
        ret
    endp
    
    ;wait until user presses a key
    waitForUserInput PROC
        mov ah, 08h
        int 21h
        ret
    endp
    
    
    ;Reads a line into text2
    readLines2 PROC
        xor si, si
        startLines2:
            lea dx, [text2 + si]      ;where to store read characters
            mov ax, 3F00h             ;ms-dos read from file
            mov bx, [filehandle]      ;set filehandle to bx for reading
            mov cx, 1                 ;read one char
            int 21h
            mov cx, ax                ;store read count into cx for further use
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
            mov cx, 1                 ;read one byte
            int 21h
            mov al, [text2 + si]
            cmp al, 0Ah               ;compare with 0a - newline
            jz doneLines2
        doneLines2:
        dec si
        lea di, [text2 + si]
        mov [di], 0                   ;append 0 to text2
        inc si
        lea di, [text2 + si]
        mov [di], BYTE PTR '$'        ;append $ to text2
        dec si
        ret
    endp
    
    
        
    
    readArguments PROC
    
        ;load PSP argument at 3rd position <file.exe>..X...
        ;given that only -p and -h are supported,
        ;only distinguishing those 2 is necessary
        ;although any ..h or ..p at those positions
        ;will trigger the alterante functions
        mov di, offset 83h
        mov al, [di]
        
        mov bx, @data
        mov ds, bx
        
        cmp al, BYTE PTR 'p'
        jz SwitchP
        cmp al, BYTE PTR 'h'
        jz SwitchHelp
        jmp noArgs
        
        ;IF -p is found, set max printed to 25,
        ;when indexing from 1 upwards, the printResult
        ;macro will stop and wait for user input
        SwitchP:
            lea di, [printedMax]
            mov [di], BYTE PTR 25
            jmp noArgs
        
        ;Prints help message
        SwitchHelp:
            mov ah, 09h
            lea dx, helpMsg
            int 21h
            jmp noArgs
        
        
        noArgs:
        ret
    endp
    
    
    main:
            call readArguments
            
            
            fopen
            
            readLines1
            ;always print the first line
            mov ax, 1
            call printResult
            call readLines2
            push cx
            ;cx contains the number of bytes read from file
            
            mainCycle:
            
                compareLines        ;ax set to 1 or 0 based on equality
                call printResult    ;prints uniques after comparison
                
                pop cx
                cmp cx, 0           ;if bytes read == 0, EOF
                jz EOFFound
                
                cmp ax, 1           ;check for string equality
                jz equalLines
                    copyT2toT1      ;if not equal, also use new one to compare
                equalLines:         
                    call readLines2 ;read next line to text2
                    push cx         ;push cx with number of bytes read
                    jmp mainCycle
                
            EOFFound:
            ;flush the text2 onto the screen
            ;since theres no more to compare against
            mov ah, 09h
            lea dx, text2
            int 21h
            ;MSDOS program end
            mov ax, 4c00h
            int 21h
    end main