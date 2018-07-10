; Multiplication of Polynomials


AVAIL	  GREG	    
POOLMAX	  GREG
SEQMIN	  GREG
ZERO	  GREG	    0
t 	  IS	    $255
c	  IS	    8*3		Nodesize, (max 256)
capacity  IS	    #10		max number of c-Byte nodes 
LINK	  IS 	    0
INFO	  IS	    8
COEF	  IS	    8
SIGN	  IS	    16
ABC	  IS	    SIGN
A	  IS	    18
B	  IS	    20
C	  IS	    22

          LOC       Data_Segment
	  GREG	    @
L0	  OCTA      0
	  LOC	    @+(16-(@%16))+c*capacity
	  GREG	    @
POLY	  OCTA	    0,0,0

	  LOC	    #100
Main	  PUSHJ	    $0,:Initialize
	  PUSHJ	    $0,:MultPoly
	  TRAP      0,Halt,0
	  
	  PREFIX    Initialize:
P	  IS	    $0
Q	  IS	    $1
M	  IS	    $2
retaddr	  IS	    $4
result	  IS	    $5
:Initialize GET     retaddr,:rJ
	  LDA	    P,:POLY
	  ADD	    Q,P,8
	  ADD	    M,Q,8
	  LDA	    :POOLMAX,:L0
	  LDA	    :SEQMIN,:POLY
	  SET	    :ZERO,0
;	  HEAD
	  SET	    (result+1),P
	  SET	    (result+2),0
	  SUB	    (result+3),:ZERO,1
	  SET	    (result+4),0
	  SET	    (result+5),0
	  SET	    (result+6),1
	  PUSHJ	    result,:InsertLeft
;	  5y^4
	  SET	    (result+1),P
	  SET	    (result+2),5
	  SET	    (result+3),0
	  SET	    (result+4),0
	  SET	    (result+5),4
	  SET	    (result+6),0
	  PUSHJ	    result,:InsertLeft
;	  4xy^3
	  SET	    (result+1),P
	  SET	    (result+2),4
	  SET	    (result+3),0
	  SET	    (result+4),1
	  SET	    (result+5),3
	  SET	    (result+6),0
	  PUSHJ	    result,:InsertLeft
;	  3x^2y^2
	  SET	    (result+1),P
	  SET	    (result+2),3
	  SET	    (result+3),0
	  SET	    (result+4),2
	  SET	    (result+5),2
	  SET	    (result+6),0
	  PUSHJ	    result,:InsertLeft
;	  2x^3y
	  SET	    (result+1),P
	  SET	    (result+2),2
	  SET	    (result+3),0
	  SET	    (result+4),3
	  SET	    (result+5),1
	  SET	    (result+6),0
	  PUSHJ	    result,:InsertLeft
;	  x^4
	  SET	    (result+1),P
	  SET	    (result+2),1
	  SET	    (result+3),0
	  SET	    (result+4),4
	  SET	    (result+5),0
	  SET	    (result+6),0
	  PUSHJ	    result,:InsertLeft
;	  HEAD
	  SET	    (result+1),Q
	  SET	    (result+2),0
	  SUB	    (result+3),:ZERO,1
	  SET	    (result+4),0
	  SET	    (result+5),0
	  SET	    (result+6),1
	  PUSHJ	    result,:InsertLeft
;	  HEAD
	  SET	    (result+1),M
	  SET	    (result+2),0
	  SUB	    (result+3),:ZERO,1
	  SET	    (result+4),0
	  SET	    (result+5),0
	  SET	    (result+6),1
	  PUSHJ	    result,:InsertLeft
;	  y^2
	  SET	    (result+1),M
	  SET	    (result+2),1
	  SET	    (result+3),0
	  SET	    (result+4),0
	  SET	    (result+5),2
	  SET	    (result+6),0
	  PUSHJ	    result,:InsertLeft
;	  -2xy
	  SET	    (result+1),M
	  SUB	    (result+2),:ZERO,2
	  SET	    (result+3),0
	  SET	    (result+4),1
	  SET	    (result+5),1
	  SET	    (result+6),0
	  PUSHJ	    result,:InsertLeft
;	  x^2
	  SET	    (result+1),M
	  SET	    (result+2),1
	  SET	    (result+3),0
	  SET	    (result+4),2
	  SET	    (result+5),0
	  SET	    (result+6),0
	  PUSHJ	    result,:InsertLeft
	  
	  PUT	    :rJ,retaddr
	  SET	    $0,P
	  SET	    $1,Q
	  SET	    $2,M
	  POP	    4,0
	  PREFIX    :

	  PREFIX    MultPoly:
Paddr	  IS	    $0
Qaddr	  IS	    $1
Maddr	  IS	    $2
P	  IS	    $3
Q	  IS	    $4
M	  IS	    $5
retaddr	  IS	    $6
Q1	  IS	    $7
Q2	  IS	    $8
coefP	  IS	    $9
tmp	  IS	    $10
:MultPoly GET       retaddr,:rJ
;	  M1. [Next Multiplier.]
	  LDO 	    M,Maddr,:LINK
1H	  LDO	    M,M,:LINK		    M ← LINK(M)
	  LDO	    :t,M,:ABC
	  BN	    :t,8F
;	  M2. [Multiply Cycle.]
;	  A1. [Initialize]
	  LDO	    P,Paddr,:LINK
	  LDO	    Q,Qaddr,:LINK
	  LDO	    P,P,:LINK		    P ← LINK(P)
	  SET	    Q1,Q		    Q1 ← Q
	  LDO	    Q,Q,:LINK		    Q ← LINK(Q)
;	  A2. [ABC(P):ABC(Q).]
2H	  LDO       tmp,P,:ABC		    ABC(P)
	  PBNN	    tmp,6F
	  ADD	    tmp,:ZERO,1
	  INCH	    tmp,#ffff
	  JMP	    7F
6H	  LDO	    :t,M,:ABC
	  ADD	    tmp,tmp,:t		    ABC(P) ⇝ ABC(P) + ABC(M) or -1
7H	  LDO       :t,Q,:ABC
	  CMP	    :t,tmp,:t
	  BNN	    :t,3F
	  SET	    Q1,Q		    Q1 ← Q
	  LDO	    Q,Q,:LINK		    Q ← LINK(Q)
	  JMP	    2B
3H	  BNZ	    :t,5F
;	  A3. [Add coefficients.]
	  BN 	    tmp,1B
	  LDO	    :t,Q,:COEF
	  LDO	    coefP,P,:COEF	    COEF(P)
	  LDO	    tmp,M,:COEF
	  MUL	    tmp,tmp,coefP	    
	  ADD	    :t,:t,tmp
	  STO	    :t,Q,:COEF	            COEF(Q) ← COEF(Q) + COEF(P)
	  PBZ	    :t,4F
	  LDO	    P,P,:LINK		    P ← LINK(P)
	  SET	    Q1,Q		    Q1 ← Q
	  LDO	    Q,Q,:LINK		    Q ← LINK(Q)
	  JMP	    2B
4H	  SET	    Q2,Q
	  LDO	    Q,Q,:LINK
	  STO	    Q,Q1,:LINK		    LINK(Q1) ← Q ← LINK(Q)
	  SET	    (tmp+1),Q2
	  PUSHJ	    tmp,:Dealloc
	  LDO	    P,P,:LINK		    P ← LINK(P)
	  JMP	    2B
5H	  PUSHJ	    tmp,:Alloc
	  SET	    Q2,tmp
	  LDO	    coefP,P,:COEF	    COEF(P)
	  LDO	    :t,M,:COEF
	  MUL	    :t,:t,coefP
	  STO	    :t,Q2,:COEF		    COEF(Q2) ← COEF(P)
	  LDO       :t,P,:ABC		    ABC(P)
	  PBNN	    :t,6F
	  ADD	    :t,:ZERO,1
	  INCH	    :t,#ffff
	  JMP	    7F
6H	  LDO	    tmp,M,:ABC
	  ADD	    :t,tmp,:t		    ABC(P) ⇝ ABC(P) + ABC(M) or -1
7H	  STO	    :t,Q2,:ABC		    ABC(Q2) ← ABC(P)
	  STO	    Q,Q2,:LINK		    LINK(Q2) ← Q
	  STO	    Q2,Q1,:LINK		    LINK(Q1) ← Q2
	  SET	    Q1,Q2		    Q1 ← Q2
	  LDO	    P,P,:LINK		    P ← LINK(P)
	  JMP	    2B
8H	  PUT	    :rJ,retaddr
	  POP	    0,0
	  PREFIX    :

	  PREFIX    InsertLeft:
; 	  Calling Sequence:
;	  SET	    $(X+1),POLY    Pointer to address that contains the POLY pointer
;	  SET	    $(X+2),COEF
;	  SET	    $(X+3),SIGN
;	  SET	    $(X+4),A
;	  SET	    $(X+5),B
;	  SET	    $(X+6),C
;	  PUSHJ	    $(X),:InsertLeft
POLY	  IS	    $0
COEF	  IS	    $1
SIGN	  IS	    $2
A	  IS	    $3
B	  IS	    $4
C	  IS	    $5
retaddr	  IS	    $6
P	  IS	    $7
tmp2	  IS	    $8
:InsertLeft   GET   retaddr,:rJ
	  PUSHJ	    P,:Alloc    P ⇐ AVAIL
;	  INFO(P) ← Y (offset of 8 is specific data format)
	  STO	    COEF,P,:COEF
	  STW	    SIGN,P,:SIGN
	  STW	    A,P,:A
	  STW	    B,P,:B
	  STW	    C,P,:C
;	  If POLY = Λ, then POLY ← LINK(P) ← P
	  LDO	    :t,POLY,:LINK       Value of POLY
	  PBNZ	    :t,1F
	  STO	    P,P,:LINK
	  STO	    P,POLY,:LINK
	  JMP	    2F
;	  LINK(P) ← LINK(POLY)
1H	  LDO	    tmp2,:t,:LINK      LINK(POLY)
	  STO	    tmp2,P,:LINK
;	  LINK(POLY) ← P
	  STO	    P,:t,:LINK
2H	  PUT	    :rJ,retaddr
	  POP	    0,0
	  PREFIX    :

	  PREFIX    InsertRight:
; 	  Calling Sequence:
;	  SET	    $(X+1),POLY    Pointer to address that contains the POLY pointer
;	  SET	    $(X+2),COEF
;	  SET	    $(X+3),SIGN
;	  SET	    $(X+4),A
;	  SET	    $(X+5),B
;	  SET	    $(X+6),C
;	  PUSHJ	    $(X),:InsertRight
POLY	  IS	    $0
COEF	  IS	    $1
SIGN	  IS	    $2
A	  IS	    $3
B	  IS	    $4
C	  IS	    $5
retaddr	  IS	    $6
P	  IS	    $7
tmp2	  IS	    $8
:InsertRight  GET   retaddr,:rJ
	  SET 	    (tmp2+1),POLY
	  SET	    (tmp2+2),COEF
	  SET	    (tmp2+3),SIGN
	  SET	    (tmp2+4),A
	  SET	    (tmp2+5),B
	  SET	    (tmp2+6),C
	  PUSHJ	    tmp2,:InsertLeft
	  LDO	    :t,POLY,:LINK
	  LDO	    P,:t,:LINK    tmp2 ← LINK(POLY)=P
	  STO	    P,POLY,:LINK
	  PUT	    :rJ,retaddr
	  POP	    1,0
	  PREFIX    :

	  PREFIX    DeleteLeft:
; 	  Calling Sequence:
;	  SET	    $(X+1),POLY    Pointer to address that contains the POLY pointer
;	  PUSHJ	    $(X),:DeleteLeft
POLY	  IS	    $0
COEF	  IS	    $1
SIGN	  IS	    $2
A	  IS	    $3
B	  IS	    $4
C	  IS	    $5
retaddr	  IS	    $6
POLYval	  IS	    $7
P	  IS	    $8
tmp	  IS	    $9
:DeleteLeft   GET   retaddr,:rJ
;	  If POLY = Λ, then UNDERFLOW
	  LDO	    POLYval,POLY,:LINK
	  PBNZ	    POLYval,1F
	  TRAP	    0,:Halt,0	  Error: UNDERFLOW!
;	  P ← LINK(POLY)
1H	  LDO	    P,POLYval,:LINK
;	  Y ← INFO(P)
	  LDO	    COEF,P,:COEF
	  LDW	    SIGN,P,:SIGN
	  LDW	    A,P,:A
	  LDW	    B,P,:B
	  LDW	    C,P,:C
;	  LINK(POLY) ← LINK(P)
	  LDO	    :t,P,:LINK
	  STO	    :t,POLYval,:LINK
	  SET	    (tmp+1),P
	  PUSHJ	    tmp,:Dealloc
;	  If POLY = P, then POLY ← Λ
	  CMP	    :t,POLYval,P
	  PBNZ	    :t,2F
	  STO	    :t,POLY,:LINK   since this line is only executed when t=0, POLY ← Λ
2H	  SET	    $0,SIGN
	  SET	    $1,A
	  SET	    $2,B
	  SET	    $3,C
	  SET	    $4,COEF
	  PUT	    :rJ,retaddr
	  POP	    5,0
	  PREFIX    :

	  PREFIX    Alloc:
X	  IS	    $0
:Alloc	  PBNZ	    :AVAIL,1F
	  SET	    X,:POOLMAX
	  ADD	    :POOLMAX,X,:c
	  CMP	    :t,:POOLMAX,:SEQMIN
	  PBNP	    :t,2F
	  TRAP	    0,:Halt,0        Overflow (no nodes left)
1H	  SET	    X,:AVAIL
	  LDO	    :AVAIL,:AVAIL,:LINK
2H	  POP	    1,0
	  PREFIX    :
	  
	  PREFIX    Dealloc:
;	  Doesn't check if trying to dealloc a node that was never alloc'd	  
X	  IS	    $0
:Dealloc  STO	    :AVAIL,X,:LINK
1H	  SET	    :AVAIL,X
	  POP	    0,0
	  PREFIX    :
