/*
    NAME: Gavyn Mathes
    COURSE: ECE 273
    SECTION: 002
    DATE: 1/31/2023
    FILE: gmathes_273_002_2.s
    PURPOSE: This program is here to develop our simple arithmetic skills.
*/

# ---------------------------------------------------------------------------
# Global variables (4 bytes each, common in .bss)
# digit1, digit2, digit3 : inputs (integers)
# diff                   : output of dodiff
# sum, product           : outputs of dosumprod
# remainder              : output of doremainder
# ---------------------------------------------------------------------------
.comm digit1,    4
.comm digit2,    4
.comm digit3,    4
.comm diff,      4
.comm sum,       4
.comm product,   4
.comm remainder, 4


/* 
    FUNCTION: dodiff
    ARGUMENTS: Uses global variables digit1, digit2, digit3.
    RETURNS:   Nothing (writes result into global variable diff).
    PURPOSE:   Compute:
               diff = (digit1 * digit1) + (digit2 * digit2) - (digit3 * digit3)
*/
.globl dodiff
.type  dodiff, @function
dodiff:
    # ---------------- Prologue ----------------
    pushl %ebp           # Save old base pointer
    movl  %esp, %ebp     # Set up new stack frame
    pushl %ebx           # Save callee-saved register ebx

    # ---------------- Body --------------------
    # We will compute:
    #   t1 = digit1 * digit1  -> EAX
    #   t2 = digit2 * digit2  -> EBX
    #   t3 = digit3 * digit3  -> ECX
    #   diff = t1 + t2 - t3

    # Compute t3 = digit3 * digit3, store in ECX
    movl digit3, %eax     # EAX = digit3
    mull digit3           # EDX:EAX = digit3 * digit3 (unsigned)
    movl %eax, %ecx       # ECX = t3 = digit3^2

    # Compute t2 = digit2 * digit2, store in EBX
    movl digit2, %eax     # EAX = digit2
    mull digit2           # EDX:EAX = digit2 * digit2
    movl %eax, %ebx       # EBX = t2 = digit2^2

    # Compute t1 = digit1 * digit1, leave in EAX
    movl digit1, %eax     # EAX = digit1
    mull digit1           # EDX:EAX = digit1 * digit1
                          # EAX = t1 = digit1^2

    # EBX currently = t2, ECX = t3, EAX = t1
    # First: EBX = t2 - t3
    subl %ecx, %ebx       # EBX = t2 - t3

    # Then: EAX = t1 + (t2 - t3)
    addl %ebx, %eax       # EAX = t1 + (t2 - t3)

    # Store final result into global variable diff
    movl %eax, diff

    # ---------------- Epilogue ----------------
    movl %ebp, %esp       # Restore stack pointer
    popl %ebx             # Restore EBX
    popl %ebp             # Restore old base pointer
    ret


/* 
    FUNCTION: dosumprod
    ARGUMENTS: Uses global variables digit1, digit2, digit3.
    RETURNS:   Nothing (writes results into global variables sum and product).
    PURPOSE:   Compute:
               sum     = digit1 + digit2 + digit3
               product = digit1 * digit2 * digit3
*/
.globl dosumprod
.type  dosumprod, @function
dosumprod:
    # ---------------- Prologue ----------------
    pushl %ebp
    movl  %esp, %ebp
    pushl %ebx

    # ---------------- Body --------------------
    # Load digits into registers:
    #   EAX <- digit1
    #   EBX <- digit2
    #   ECX <- digit3
    movl digit1, %eax
    movl digit2, %ebx
    movl digit3, %ecx

    # sum = digit1 + digit2 + digit3
    addl %ecx, %ebx       # EBX = digit2 + digit3
    addl %ebx, %eax       # EAX = digit1 + (digit2 + digit3) = sum
    movl %eax, sum        # Store sum

    # product = digit1 * digit2 * digit3
    # We'll reuse EAX for the product:
    movl digit3, %eax     # EAX = digit3
    mull digit2           # EDX:EAX = digit3 * digit2
    mull digit1           # EDX:EAX = (digit3 * digit2) * digit1
    movl %eax, product    # Store product (low 32 bits)

    # ---------------- Epilogue ----------------
    movl %ebp, %esp
    popl %ebx
    popl %ebp
    ret


/* 
    FUNCTION: doremainder
    ARGUMENTS: Uses global variables product and sum.
    RETURNS:   Nothing (writes result into global variable remainder).
    PURPOSE:   Compute:
               remainder = product % sum
               using unsigned integer division.
*/
.globl doremainder
.type  doremainder, @function
doremainder:
    # ---------------- Prologue ----------------
    pushl %ebp
    movl  %esp, %ebp
    pushl %ebx

    # ---------------- Body --------------------
    # We want: remainder = product % sum
    # For divl:
    #   dividend = EDX:EAX
    #   divisor  = sum
    #   quotient -> EAX
    #   remainder -> EDX

    movl $0, %edx         # Clear high 32 bits of dividend
    movl product, %eax    # EAX = product (low 32 bits)
    divl sum              # Unsigned divide EDX:EAX by sum

    movl %edx, remainder  # remainder = EDX

    # ---------------- Epilogue ----------------
    movl %ebp, %esp
    popl %ebx
    popl %ebp
    ret

# End assembly stub
# Do not forget the required blank line here!

