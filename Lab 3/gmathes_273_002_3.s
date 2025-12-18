/*
    NAME: Gavyn Mathes
    COURSE: ECE 273
    SECTION: 002
    DATE: 2/17/2023
    FILE: gmathes_273_002_3.s
    PURPOSE: This program is here to develop our ability to manipulate control
             flow in assembly and use this manipulation to create if statements.

    Logic (high level, C-style):

    extern int i, j, k;
    extern int tri_type;   // 0 = not triangle, 1 = equilateral,
                           // 2 = isosceles, 3 = scalene
    extern int match;

    void classify(void) {
        if (i == 0 || j == 0 || k == 0) {
            tri_type = 0;
            return;
        }

        match = 0;
        if (i == j) match += 1;
        if (i == k) match += 2;
        if (j == k) match += 3;

        if (match != 0) {
            if (match == 1) {
                // i == j only → check triangle inequality using i + j <= k
                if ((i + j) <= k)
                    tri_type = 0;     // not a triangle
                else
                    // fall through to later checks (eventually isosceles)
                    ...
            } else if (match != 2) {   // match == 6 (all equal) or 3 (j==k) or something else
                if (match == 6) {
                    // equilateral
                    tri_type = 1;
                } else {
                    // other equality cases
                    ...
                }
            } else {
                // match == 2 (i == k only)
                ...
            }
            // final isosceles case sets tri_type = 2
        } else {
            // no equal sides → check triangle inequality and set
            // tri_type = 0 (not triangle) or tri_type = 3 (scalene).
        }
    }
*/

.globl classify
.type  classify, @function
classify:
    /* prolog: standard cdecl frame with saved ebx */
    pushl %ebp
    movl  %esp, %ebp
    pushl %ebx

/* --------------------------------------------------------------------
   First: check for zero sides.
   if (i == 0 || j == 0 || k == 0) {
       tri_type = 0;
       return;
   }
-------------------------------------------------------------------- */
    # Check i == 0
    movl i, %eax          # eax = i
    cmpl $0, %eax         # compare i with 0
    jz   tri0             # if i == 0 -> tri_type = 0 and return

    # Check j == 0
    movl j, %eax          # eax = j
    cmpl $0, %eax
    jz   tri0             # if j == 0 -> tri_type = 0 and return

    # Check k == 0
    movl k, %eax          # eax = k
    cmpl $0, %eax
    jz   tri0             # if k == 0 -> tri_type = 0 and return

/* --------------------------------------------------------------------
   match = 0;
   if (i == j) match += 1;
   if (i == k) match += 2;
   if (j == k) match += 3;
   This "match" pattern encodes which sides are equal:
   - 0: no equal sides
   - 1: i == j
   - 2: i == k
   - 3: j == k
   - 6: i == j == k  (1 + 2 + 3)
-------------------------------------------------------------------- */
    movl $0, match        # match = 0

    # if (i == j) match += 1;
    movl i, %eax
    cmpl j, %eax          # compare i with j (eax - j)
    jne  addMatch2        # if i != j, skip increment
    addl $1, match        # match += 1

addMatch2:
    # if (i == k) match += 2;
    movl i, %eax
    cmpl k, %eax          # compare i with k
    jne  addMatch3        # if i != k, skip increment
    addl $2, match        # match += 2

addMatch3:
    # if (j == k) match += 3;
    movl j, %eax
    cmpl k, %eax          # compare j with k
    jne  leaveMatch       # if j != k, skip increment
    addl $3, match        # match += 3

leaveMatch:
    # if (match != 0) { ... } else { finalCheckToSeeIfTriangle }
    movl match, %eax
    cmpl $0, %eax
    jz   finalCheckToSeeIfTriangle    # no equal sides -> test triangle inequality for scalene

/* --------------------------------------------------------------------
   At this point: match != 0 → at least one pair of equal sides.

   We break it into cases:
   - match == 1   : i == j only
   - match == 2   : i == k only
   - match == 3   : j == k only
   - match == 6   : i == j == k (equilateral)
-------------------------------------------------------------------- */

    # if (match == 1) { check (i + j) <= k }
    movl match, %eax
    cmpl $1, %eax
    jnz  elseEqualToMatch1    # if match != 1, skip this block

    # if ((i + j) <= k) tri_type = 0;  // can't form triangle
    movl j, %eax
    addl i, %eax              # eax = i + j
    cmpl k, %eax              # compare (i + j) with k  → (i+j) - k
    jnle elseEqualToMatch1    # if (i + j) > k, it's still a potential triangle, continue
    jmp  tri0                 # (i + j) <= k → not a triangle (degenerate or impossible)

elseEqualToMatch1:
    # if (match != 2) ...
    movl match, %eax
    cmpl $2, %eax
    jz   elseNotEqualToMatch2 # if match == 2, skip ahead to final isosceles check

    # Now match is NOT 1 and NOT 2, but non-zero ⇒ 3 or 6

    # if (match == 6) → all three sides equal → equilateral
    movl match, %eax
    cmpl $6, %eax
    jnz  elseEqualToMatch6    # if match != 6, go test another equality case
    jmp  tri1                 # match == 6 → tri_type = 1 (equilateral)

elseEqualToMatch6:
    # Here: match is non-zero, not 1, not 2, not 6 → effectively match == 3 (j == k)

    # Check triangle inequality: if ((j + k) <= i) tri_type = 0;
    movl j, %eax
    addl k, %eax              # eax = j + k
    cmpl i, %eax              # compare (j + k) with i
    jnle elseNotEqualToMatch2 # if (j + k) > i, still okay, go on
    jmp  tri0                 # if (j + k) <= i → not a triangle

elseNotEqualToMatch2:
    # This block handles the final isosceles case:
    # if ((i + k) <= j) tri_type = 0;
    # else tri_type = 2 (isosceles).

    movl i, %eax
    addl k, %eax              # eax = i + k
    cmpl j, %eax              # compare (i + k) with j
    jnle tri2                 # if (i + k) > j → valid isosceles → tri2
    jmp  tri0                 # if (i + k) <= j → not a triangle

/* --------------------------------------------------------------------
   No equal sides: possible scalene or invalid

   if ((i + j) <= k || (j + k) <= i || (i + k) <= j)
       tri_type = 0;   // cannot form triangle
   else
       tri_type = 3;   // scalene
-------------------------------------------------------------------- */
finalCheckToSeeIfTriangle:
    # Check (i + j) <= k
    movl j, %eax
    addl i, %eax              # eax = i + j
    cmpl k, %eax              # (i + j) - k
    jle  tri0                 # if (i + j) <= k → not a triangle

    # Check (j + k) <= i
    movl j, %eax
    addl k, %eax              # eax = j + k
    cmpl i, %eax              # (j + k) - i
    jle  tri0                 # if (j + k) <= i → not a triangle

    # Check (i + k) <= j
    movl i, %eax
    addl k, %eax              # eax = i + k
    cmpl j, %eax              # (i + k) - j
    jle  tri0                 # if (i + k) <= j → not a triangle

    # Passed all three checks → valid scalene triangle
    jmp  tri3


# --------------------------------------------------------------------
# tri_type setters
# --------------------------------------------------------------------
tri0:                        # tri_type = 0 → NOT a triangle
    movl $0, tri_type
    jmp  return

tri1:                        # tri_type = 1 → Equilateral triangle
    movl $1, tri_type
    jmp  return

tri2:                        # tri_type = 2 → Isosceles triangle
    movl $2, tri_type
    jmp  return

tri3:                        # tri_type = 3 → Scalene triangle
    movl $3, tri_type
    jmp  return

return:
    /* epilog */
    movl %ebp, %esp          # restore stack pointer
    popl %ebx                # restore callee-saved register
    popl %ebp                # restore base pointer
    ret


/* Global variables (4-byte ints) */
.comm i,        4
.comm j,        4
.comm k,        4
.comm tri_type, 4
.comm match,    4

/* end assembly stub */
