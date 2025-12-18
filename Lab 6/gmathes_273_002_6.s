/*
    NAME:       Gavyn Mathes
    COURSE:     ECE 2730
    SECTION:    003
    DATE:       4/17/2023
    FILE:       gmathes_273_002_6.s
    PURPOSE:    The goal of this program is to understand how to call recursive functions,
                use the stack, callee-saved registers, how to pass arguments to a function,
                and how returns work.
*/

/* 
    FUNCTION:   Factorial
    ARGUMENTS:  int n  (passed on the stack)
    RETURNS:    int    (in %eax)
    PURPOSE:    Compute n! recursively:
                    if n == 0 or n == 1 → return 1
                    else                → return n * Factorial(n - 1)
*/

.globl Factorial
.type  Factorial, @function
Factorial:
    /* ---------------- Prolog ----------------
       Standard cdecl prologue:
       - Save old %ebp
       - Establish new stack frame
       - Save callee-saved registers (ebx, esi, edi)
       ---------------------------------------- */
    pushl %ebp            # save caller's base pointer
    movl  %esp, %ebp      # set up this function's frame

    pushl %ebx            # save callee-saved registers
    pushl %esi
    pushl %edi

    # No local variables are allocated on the stack here,
    # so we don't subl from %esp.

    # Convention (cdecl, 32-bit):
    #   [ebp+8]  = first argument = n
    #
    # We’ll use:
    #   %ebx for n
    #   %eax for return value

    # Load n into %ebx
    movl  8(%ebp), %ebx    # ebx = n

    # ---------------- Base cases ----------------
    # if (n == 0) return 1;
    cmpl  $0, %ebx
    jz    base_case

    # if (n == 1) return 1;
    cmpl  $1, %ebx
    jz    base_case

    # ---------------- Recursive case ----------------
    # For n > 1:
    #   return n * Factorial(n - 1);
    #
    # 1) Compute n - 1 into a register
    movl  %ebx, %ecx       # ecx = n
    subl  $1, %ecx         # ecx = n - 1

    # 2) Pass (n - 1) as argument and call Factorial
    pushl %ecx             # push (n - 1) as argument
    call  Factorial        # Factorial(n - 1)
    addl  $4, %esp         # pop argument (clean up stack)

    # On return:
    #   - %eax contains Factorial(n - 1)
    #   - %ebx still contains n
    #
    # 3) Multiply:
    #    eax = n * Factorial(n - 1)
    mull  %ebx             # EDX:EAX = EAX * EBX → eax holds low 32 bits
    jmp   done             # jump to epilogue

base_case:
    # Base case: return 1
    movl  $1, %eax         # eax = 1

done:
    # ---------------- Epilog ----------------
    popl  %edi             # restore callee-saved registers
    popl  %esi
    popl  %ebx

    movl  %ebp, %esp       # restore stack pointer
    popl  %ebp             # restore caller's base pointer
    ret                    # return to caller with result in %eax

/* end assembly stub */
