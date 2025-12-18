/*
    NAME:       Gavyn Mathes
    COURSE:     ECE 2730
    SECTION:    002
    DATE:       3/6/2023
    FILE:       gmathes_273_002_4.s
    PURPOSE:    The goal of this program is to convert an ASCII string number
                into an actual integer.
*/

/* 
    FUNCTION:   AtoI
    ARGUMENTS:  No explicit arguments (uses global variables: ascii, intptr,
                sign, i, multiplier)
    RETURNS:    No direct return value; stores the converted integer into
                *intptr, taking into account sign and digit characters.
    PURPOSE:    Convert an ASCII string number into an actual integer.
*/
/* begin assembly stub */
.globl AtoI
.type AtoI,@function
AtoI:
    /* --------------- Prolog: save caller state, build stack frame --------------- */
    pushl %ebp            # Save old base pointer
    movl  %esp, %ebp      # Establish new stack frame
    pushl %ebx            # Save callee-saved register EBX
    pushl %esi            # Save ESI (even though we don't use it here)
    pushl %edi            # Save EDI

    /* --------------- Initialize sign = +1 --------------- */
    movl $1, sign         # Default sign is positive

    /* -----------------------------------------------------------------
       Skip leading whitespace:
       while (*ascii == ' ' || *ascii == '\t') { advance pointer }
       - ascii: global char* to input string
       - EBX: index offset from start of ascii
       - ECX: base pointer to ascii
       ----------------------------------------------------------------- */
    movl $0, %ebx         # ebx = 0 (offset into string)
    movl ascii, %ecx      # ecx = ascii (base address of string)

beginOfSkipLeadingSpaces:
        movl $0, %edx                     # clear edx
        movl (%ecx,%ebx,1), %edx          # edx = ascii[ebx]
        cmpb $32, %dl                     # compare with ' ' (space)
        jz   skippingSpaces               # if space, skip it
        cmpb $9, %dl                      # compare with '\t' (tab)
        jz   skippingSpaces               # if tab, skip it
        jmp  doneSkippingSpaces           # otherwise, done skipping

    # Found space or tab; move to next character
skippingSpaces:
        addl $1, %ebx                     # ebx++
        jmp  beginOfSkipLeadingSpaces     # repeat check

doneSkippingSpaces:
        # At this point ascii[ebx] is the first non-space / non-tab character
        movl $0, %edx
        movl (%ecx,%ebx,1), %edx          # edx = ascii[ebx]

        # Check for optional '+' sign
        cmpb $43, %dl                     # '+' = ASCII 43
        jz   incrementDueToSign           # if '+', move past it

        # Check for optional '-' sign
        cmpb $45, %dl                     # '-' = ASCII 45
        jnz  exitSignIfStatement          # if not '-', no sign change
        movl $-1, sign                    # if '-', sign = -1

    # If we saw '+' or '-', advance offset once
incrementDueToSign:
        addl $1, %ebx                     # skip the sign character

exitSignIfStatement:
    /* -----------------------------------------------------------------
       Initialize *intptr = 0

       intptr is a global pointer to an int. We want to store the final
       numeric value into *intptr, so start from 0.
       ----------------------------------------------------------------- */
    movl intptr, %eax                     # eax = intptr (address of int)
    movl $0, (%eax)                       # *intptr = 0

    /* -----------------------------------------------------------------
       Adjust ECX so it points directly at first digit (or first non-digit)
       ascii + offset (ebx) from skipping whitespace and optional sign.
       ----------------------------------------------------------------- */
    addl %ebx, %ecx                       # ecx = ascii + ebx

    /* -----------------------------------------------------------------
       Determine the length of the digit sequence.

       i will store the index of the last digit (i.e., ones place).
       Loop:
         while (ascii[i] >= '0' && ascii[i] <= '9') i++;
       ----------------------------------------------------------------- */
    movl $0, %ebx                         # clear ebx (not strictly needed now)
    movl $0, i                            # i = 0
    movl i, %edi                          # edi = i (loop index)

loopAboutGettingLength:
        movb (%ecx, %edi, 1), %bl         # bl = ascii[edi]

        # if ascii[edi] < '0' → break
        cmpb $48, %bl                     # '0' = 48
        jnge exitForLoopAboutGettingLength

        # if ascii[edi] > '9' → break
        cmpb $57, %bl                     # '9' = 57
        jnle exitForLoopAboutGettingLength

        # Otherwise, it's a digit → increment index and keep going
        addl $1, %edi
        jmp  loopAboutGettingLength

exitForLoopAboutGettingLength:
    # edi now holds the index of the first non-digit.
    # Step back once: edi = index of LAST digit (ones position).
    subl $1, %edi
    movl %edi, i                          # i = edi

    # Initialize multiplier = 1 (ones place)
    movl $1, multiplier

    /* -----------------------------------------------------------------
       Convert ASCII digits to integer:

       For each digit from right to left:
         digit = ascii[i] - '0'
         *intptr += digit * multiplier
         multiplier *= 10
         i--

       Loop continues while i >= 0.
       ----------------------------------------------------------------- */
loopForGettingValue:
        movl $0, %eax                     # clear eax
        cmpl $0, %edi                     # compare i with 0
        jl   exitLoopForGettingValue      # if i < 0, done

        # Load ascii[i] into AL
        movb (%ecx, %edi, 1), %al         # al = ascii[i]

        # Convert from ASCII to int: '0' → 0, '1' → 1, ...
        subb $48, %al                     # al = al - '0'

        # EAX now has the digit value (0–9).
        # Multiply by current multiplier: EDX:EAX = EAX * multiplier
        mull multiplier                   # unsigned multiply by multiplier

        # Save digit * multiplier in EBX
        movl %eax, %ebx

        # Add it into *intptr
        movl intptr, %eax                 # eax = intptr (address of result)
        addl %ebx, (%eax)                 # *intptr += digit * multiplier

        # Increase multiplier by factor of 10: multiplier *= 10
        movl $10, %eax
        mull multiplier                   # EDX:EAX = 10 * multiplier
        movl %eax, multiplier             # multiplier = 10 * multiplier

        # Move to next more significant digit (one position to the left)
        subl $1, %edi                     # i--
        jmp  loopForGettingValue

    /* -----------------------------------------------------------------
       Apply sign:

       *intptr = sign * (*intptr)

       sign is either +1 or -1 from earlier logic.
       ----------------------------------------------------------------- */
exitLoopForGettingValue:
        movl sign, %eax                   # eax = sign
        movl intptr, %ecx                 # ecx = intptr (address to result)
        mull (%ecx)                       # EDX:EAX = sign * (*intptr)
        movl %eax, (%ecx)                 # *intptr = sign * (*intptr)

return:
    /* --------------- Epilog: restore registers and return --------------- */
    popl %edi
    popl %esi
    popl %ebx
    movl %ebp, %esp
    popl %ebp
    ret
/* end assembly stub */
