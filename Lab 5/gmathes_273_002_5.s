/*
    NAME:       Gavyn Mathes
    COURSE:     ECE 2730
    SECTION:    003
    DATE:       4/4/2023
    FILE:       gmathes_273_002_5.s
    PURPOSE:    The goal of this program is to understand how to call recursive
                functions, use the stack, and manage callee-saved registers.
*/

/* 
    FUNCTION:   Fib
    ARGUMENTS:  No explicit arguments (uses global_var as both input and output)
    RETURNS:    No direct return value, but writes the Fibonacci result into
                global_var.

    PROTOCOL:
      - On entry:  global_var = n
      - On exit:   global_var = Fib(n)

      Base cases:
        if n == 0 or n == 1, leave global_var as-is and return.

      Recursive case (n > 1):
        Fib(n) = Fib(n - 1) + Fib(n - 2)
        Implemented using global_var and two local ints:
          local_var = n
          temp_var  = Fib(n - 1)
          then compute Fib(n - 2) and add.
*/

/* Externally defined global variable:
   .comm global_var, 4
   is assumed to be in some other file. */

.globl Fib
.type  Fib,@function
Fib:
    /* --------------- Prologue: set up stack frame & save registers --------------- */
    pushl %ebp               # Save old base pointer
    movl  %esp, %ebp         # Establish new base pointer

    pushl %ebx               # Save callee-saved registers
    pushl %esi
    pushl %edi

    # Reserve space for 2 local ints:
    #   -4(%ebp) = local_var
    #   -8(%ebp) = temp_var
    subl  $8, %esp

    /* -----------------------------------------------------------------
       local_var = global_var;
       (Copy the current n into a local so we don't lose it.)
       ----------------------------------------------------------------- */
    movl global_var, %ebx    # ebx = global_var (n)
    movl %ebx, -4(%ebp)      # local_var = n

    /* -----------------------------------------------------------------
       Base cases:
         if (local_var == 0) return;
         else if (local_var == 1) return;

       In both cases, global_var is already equal to n, which matches
       Fib(0) = 0 and Fib(1) = 1 if the caller set global_var = n.
       ----------------------------------------------------------------- */
    cmpl $0, -4(%ebp)        # compare local_var with 0
    jz   return              # if local_var == 0 → just return

    cmpl $1, -4(%ebp)        # compare local_var with 1
    jz   return              # if local_var == 1 → just return

    /* -----------------------------------------------------------------
       Recursive case:

       // global_var = local_var - 1;
       // Fib();                // computes Fib(local_var - 1) into global_var
       // temp_var = global_var;

       ----------------------------------------------------------------- */
    movl -4(%ebp), %ebx      # ebx = local_var
    subl $1, %ebx            # ebx = local_var - 1
    movl %ebx, global_var    # global_var = local_var - 1

    call Fib                 # recursive call: Fib(local_var - 1)
                             # on return, global_var = Fib(local_var - 1)

    movl global_var, %ebx    # ebx = Fib(local_var - 1)
    movl %ebx, -8(%ebp)      # temp_var = Fib(local_var - 1)

    /* -----------------------------------------------------------------
       Now compute Fib(local_var - 2):

       // global_var = local_var - 2;
       // Fib();                // computes Fib(local_var - 2) into global_var

       ----------------------------------------------------------------- */
    movl -4(%ebp), %ebx      # ebx = local_var
    subl $2, %ebx            # ebx = local_var - 2
    movl %ebx, global_var    # global_var = local_var - 2

    call Fib                 # recursive call: Fib(local_var - 2)
                             # on return, global_var = Fib(local_var - 2)

    /* -----------------------------------------------------------------
       Combine the two results:

       // temp_var = temp_var + global_var;
       // global_var = temp_var;

       So in the end,
         global_var = Fib(local_var - 1) + Fib(local_var - 2)
                    = Fib(n)

       ----------------------------------------------------------------- */
    movl -8(%ebp), %ebx      # ebx = temp_var = Fib(local_var - 1)
    addl global_var, %ebx    # ebx = Fib(n - 1) + Fib(n - 2)
    movl %ebx, -8(%ebp)      # temp_var = ebx
    movl %ebx, global_var    # global_var = Fib(n)

return:
    /* --------------- Epilogue: restore stack and registers --------------- */
    addl $8, %esp            # release local_var and temp_var space

    popl %edi                # restore callee-saved registers
    popl %esi
    popl %ebx

    movl %ebp, %esp          # restore stack pointer
    popl %ebp                # restore base pointer
    ret

/* end assembly stub */
