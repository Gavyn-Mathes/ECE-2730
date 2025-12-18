/* begin assembly code */
/*
    NAME: Gavyn Mathes
    COURSE: ECE 273
    SECTION: 002
    DATE: 1/31/2023
    FILE: gmathes_273_002_1.s
    PURPOSE: This program is here to develop our commenting skills.
*/


/* 
    FUNCTION: asum
    ARGUMENTS: (char* s) passed on the stack at 8(%ebp)
    RETURNS: int
    PURPOSE: Add together all the ASCII values of the characters in a
             null-terminated string and return the total.
*/
.globl asum
.type asum,@function
asum:
    /* Function prologue: save old base pointer and set up new stack frame */
    pushl %ebp            /* Save caller's base pointer on the stack          */
    movl  %esp, %ebp      /* Set this function's base pointer                 */

    /* Allocate 4 bytes on the stack for local variable 'sum' (int) */
    subl  $4, %esp        /* Make room for sum at -4(%ebp)                    */

    /* Initialize sum = 0 */
    movl  $0, -4(%ebp)    /* sum = 0                                          */

.L2:
    /* Load current string pointer argument into %eax */
    movl  8(%ebp), %eax   /* %eax = s                                         */

    /* Check if we reached the null terminator: *s == 0 ? */
    cmpb  $0, (%eax)      /* Compare *s with 0                                */
    jne   .L4             /* If *s != 0, go process this character           */
    jmp   .L3             /* Else, we are at the end of the string           */

.L4:
    /* Convert current character to a signed 32-bit int in %edx */
    movl   8(%ebp), %eax  /* %eax = s (reload pointer)                        */
    movsbl (%eax), %edx   /* %edx = (signed int)(*s) (sign-extend 8 -> 32bit) */

    /* sum += *s */
    addl  %edx, -4(%ebp)  /* sum = sum + *s                                   */

    /* s++ : advance the pointer to the next character */
    incl  8(%ebp)         /* s = s + 1                                        */

    /* Loop back and check the next character */
    jmp   .L2

.L3:
    /* End of string: move sum into return register %eax */
    movl  -4(%ebp), %eax  /* return value = sum                               */
    jmp   .L1

.L1:
    /* Function epilogue: restore caller's stack frame and return */
    movl  %ebp, %esp      /* Reset stack pointer to base pointer              */
    popl  %ebp            /* Restore caller's base pointer                    */
    ret                   /* Return to caller with sum in %eax                */
/* end assembly */
/* Do not forget the required blank line here! */

