; Basic, super inefficient neural net example

#define ADD_TRAINING(InputUnit1,InputValue1,InputUnit2,InputValue2,OutputUnit,OutputValue) ;__NL__\
1H	  IS   	    InputUnit1 __NL__\
2H	  IS   	    InputValue1 __NL__\
3H	  IS   	    InputUnit2 __NL__\
4H	  IS   	    InputValue2 __NL__\
5H	  IS   	    OutputUnit __NL__\
6H	  IS   	    OutputValue __NL__\
	  SET	    (last+1),2__NL__\
	  SET	    (last+2),trainingSet__NL__\
	  PUSHJ	    last,:Push_2__NL__\
	  SET	    setPtr,last__NL__\
	  SET	    (last+1),2__NL__\
	  ADD	    subPtr,setPtr,:Y_1__NL__\
	  SET	    (last+2),subPtr__NL__\
	  PUSHJ	    last,:Push_2__NL__\
	  SET	    :t,1B-1__NL__\
	  MUL	    :t,:t,:UNIT_SIZE__NL__\
	  ADD	    :t,:t,:Unit_arr__NL__\
	  STO	    :t,last,:Y_1__NL__\
	  SETL	    :t,2B%(1<<16) 0-15__NL__\
	  INCML	    :t,(2B>>16)%(1<<32) 16-31__NL__\
	  INCMH	    :t,(2B>>32)%(1<<48) 32-47__NL__\
	  INCH	    :t,(2B>>48) 48-63__NL__\
	  STO	    :t,last,:Y_2__NL__\
	  SET	    (last+1),2__NL__\
	  SET	    (last+2),subPtr__NL__\
	  PUSHJ	    last,:Push_2__NL__\
	  SET	    :t,3B-1__NL__\
	  MUL	    :t,:t,:UNIT_SIZE__NL__\
	  ADD	    :t,:t,:Unit_arr__NL__\
	  STO	    :t,last,:Y_1__NL__\
	  SETL	    :t,4B%(1<<16) 0-15__NL__\
	  INCML	    :t,(4B>>16)%(1<<32) 16-31__NL__\
	  INCMH	    :t,(4B>>32)%(1<<48) 32-47__NL__\
	  INCH	    :t,(4B>>48) 48-63__NL__\
	  STO	    :t,last,:Y_2__NL__\
	  ADD	    subPtr,setPtr,:Y_2__NL__\
	  SET	    (last+1),2__NL__\
	  SET	    (last+2),subPtr__NL__\
	  PUSHJ	    last,:Push_2__NL__\
	  SET	    :t,5B-1__NL__\
	  MUL	    :t,:t,:UNIT_SIZE__NL__\
	  ADD	    :t,:t,:Unit_arr__NL__\
	  STO	    :t,last,:Y_1__NL__\
	  SETL	    :t,6B%(1<<16) 0-15__NL__\
	  INCML	    :t,(6B>>16)%(1<<32) 16-31__NL__\
	  INCMH	    :t,(6B>>32)%(1<<48) 32-47__NL__\
	  INCH	    :t,(6B>>48) 48-63__NL__\
	  STO	    :t,last,:Y_2

#define CREATE_GATE(gatePtr,forwardFunction,backFunction) ;__NL__\
	  GETA	    :t,:forwardFunction __NL__\
	  STO	    :t,gatePtr,:FWD_PTR __NL__\
	  GETA	    :t,:backFunction __NL__\
	  STO	    :t,gatePtr,:BACK_PTR	 

#define CREATE_PARAMETER(unitPtr,last) ;__NL__\
	  SET	    :t,1 __NL__\
	  STO	    :t,unitPtr,:IS_PARAM __NL__\
	  PUSHJ	    last,:rand __NL__\
	  STO	    last,unitPtr,:VALUE
	  
AVAIL	  GREG
POOLMAX	  GREG
SEQMIN	  GREG
AVAIL_2	  GREG
POOLMAX_2 GREG
SEQMIN_2  GREG
ZERO	  GREG
NEGONE	  GREG      -1
FONE	  GREG	    #3FF0000000000000
FTWO	  GREG	    #4000000000000000
e	  GREG	    #4005BF0A8B145769
STEP_SIZE GREG	    #3F847AE147AE147B    0.01  in 64-bit floating point
;STEP_SIZE GREG	    #3FC999999999999A    0.2   in 64-bit floating point
;STEP_SIZE GREG	    #3FF0000000000000    1     in 64-bit floating point
;STEP_SIZE GREG	    #3F50624DD2F1A9FC    0.001 in 64-bit floating point
a_init	  GREG	    #3FEAE3C24D02DEC2
b_init	  GREG	    #BFB3960EFF7BEBF6
c_init	  GREG	    #BFEFAE147AE147AE
epoch	  GREG	    

t 	  IS	    $255
inputLayer IS	    28*28
Hidden1	  IS	    16
Hidden2	  IS	    16
outputLayer IS	    10
NUM_GATES_ IS 	    Hidden1+Hidden2+outputLayer
1H	  IS	    inputLayer+inputLayer*Hidden1+Hidden1
1H	  IS	    1B+Hidden1+Hidden1*Hidden2+Hidden2
1H	  IS	    1B+Hidden2+Hidden2*outputLayer+outputLayer
1H	  IS	    1B+outputLayer
NUM_UNITS_ IS 	    1B
NUM_GATES GREG	    NUM_GATES_
NUM_UNITS GREG	    NUM_UNITS_
GATE_SIZE IS	    4*8
UNIT_SIZE IS	    6*8
c	  IS	    28		Nodesize(bytes), (max 256)
capacity  IS	    NUM_UNITS_*10 max number of c-Byte nodes 
c_2	  IS	    3*8		Nodesize(bytes), (max 256)
capacity_2 IS	    50		max number of c_2-Byte nodes 
LINK	  IS 	    0		location of NEXT pointer in a node
INFO	  IS	    8		octabyte of data in a 16-byte node
IN_UNITS  IS	    0		gate byte-offset: linked list containing all units going into a gate
OUT_UNIT  IS	    8		gate byte-offset: pointer to the unit going out of a gate
FWD_PTR	  IS	    16		gate byte-offset: forward propagation function pointer
BACK_PTR  IS 	    24		gate byte-offset: back propagation function pointer
VALUE	  IS	    0		unit byte-offset: value used during forward propagation
GRAD	  IS	    8		unit byte-offset: gradient used during back propagation
GRAD_SUM  IS	    16		unit byte-offset: summation of gradient over a batch
IS_PARAM  IS	    24		unit byte-offset: field specifying whether a unit is a parameter
IN_GATES  IS	    32		unit byte-offset: linked list containing all gates a unit is going into
OUT_GATE  IS	    40		unit byte-offset: pointer to the gate this unit is going out of
MAX_INPUTS IS	    28*28	number of units that are initialized before forward propagation
NUM_INPUTS IS	    2		number of input variables in training data
NUM_OUTPUTS IS	    1		number of output variables in training data
PARAM_UNIT IS	    8		1st octabyte of data in a 24-byte node
PARAM_VALUE IS	    16		2nd octabyte of data in a 24-byte node
Y_1	  IS	    8		1st octabyte of data in a 24-byte node
Y_2	  IS	    16		2nd octabyte of data in a 24-byte node
NUM_ITER  IS        #FF		number of times to redo the training data
imageHandle IS	    5
labelHandle IS	    6
seed	  IS	    1

          LOC       Data_Segment
Gate_arr  GREG	    @
1H	  OCTA	    0
	  LOC	    1B+GATE_SIZE*NUM_GATES_
Unit_arr  GREG	    @
1H	  OCTA	    0
	  LOC	    1B+UNIT_SIZE*NUM_UNITS_
COUNT	  GREG	    @
1H	  OCTA	    0
TOP	  GREG	    @
QLINK	  IS	    COUNT
	  LOC	    1B+(1+NUM_GATES_+MAX_INPUTS)*16
TopOutput GREG	    @
1H	  OCTA	    0
	  LOC	    1B+NUM_GATES_*8
	  GREG	    @
L0_pool	  OCTA      0
	  LOC	    @+c*capacity-8
	  GREG	    @
endOfPool OCTA	    0
L0_pool_2 IS	    endOfPool
	  LOC	    @+c_2*capacity_2-8
	  GREG	    @
endOfPool_2 OCTA    0
springParams OCTA   0
outputUnits OCTA    0
trainingSet OCTA    0
trainingStats OCTA  0
networkShape OCTA   inputLayer
	  OCTA	    Hidden1
	  OCTA	    Hidden2
	  OCTA	    outputLayer
	  OCTA	    0
fopenArgs OCTA	    0,BinaryRead
freadArgs OCTA	    readData,0
train_labels BYTE   "train-labels.idx1-ubyte",0
train_images BYTE   "train-images.idx3-ubyte",0
test_labels BYTE    "t10k-labels.idx1-ubyte",0
test_images BYTE    "t10k-images.idx3-ubyte",0
	  LOC (@+7)&-8
labels_magic TETRA #00000801
images_magic TETRA #00000803
	  LOC (@+7)&-8
readData  OCTA	    0
	  LOC	    readData+28*28
	  LOC 	    @+NUM_ITER*5*8-8
	  GREG	    @
dataDump  OCTA	    0
dmpPtr	  GREG
	  LOC	    #100
Main	  LDA	    POOLMAX,L0_pool
	  LDA	    SEQMIN,endOfPool
	  LDA	    POOLMAX_2,L0_pool_2
	  LDA	    SEQMIN_2,endOfPool_2
	  LDA	    dmpPtr,dataDump
	  PUSHJ	    $0,:CreateNetwork
	  PUSHJ	    $0,:TopSort		Determines a topological ordering of the nodes
;	  PUSHJ	    $0,:CountInputs
;	  PUSHJ	    $0,:CountInputs1
;	  TRAP	    0,Halt,0
;	  SET	    $0,5
;1H	  BZ	    $0,1F
1H	  PUSHJ	    $1,:TrainNetworkWithMNIST
	  PUSHJ	    $1,:TestNetworkWithMNIST
	  ADD	    epoch,epoch,1
;	  SUB	    $0,$0,1
	  JMP	    1B
1H	  TRAP	    0,Halt,0

	  PREFIX    TrainNetworkWithMNIST:
test	  IS	    0
train	  IS	    1
setting	  IS	    train	Temporarily set to TEST since it's a smaller dataset
retaddr	  IS	    $0
numTotalItems IS    $1
numInBatch IS 	    $2
batchSize IS	    100
last	  IS	    $3
:TrainNetworkWithMNIST GET retaddr,:rJ
	  SET	    (last+1),setting
	  PUSHJ	    last,:OpenImages
	  SET	    (last+1),setting
	  PUSHJ	    last,:OpenLabels
	  SET	    numTotalItems,last
	  SET	    (last+1),1
	  PUSHJ	    last,:ResetUnits
nextBatch BZ	    numTotalItems,batchesDone
	  SET	    numInBatch,batchSize
nextItem  BZ	    numInBatch,batchDone
	  PUSHJ	    last,:TrainSingleImage
	  SET	    (last+1),0
	  PUSHJ	    last,:ResetUnits
	  SUB	    numInBatch,numInBatch,1
	  JMP	    nextItem
batchDone SUB	    numTotalItems,numTotalItems,batchSize
	  SET	    (last+1),batchSize
	  PUSHJ	    last,:ParameterUpdate
	  SET	    (last+1),1
	  PUSHJ	    last,:ResetUnits
	  JMP	    nextBatch
batchesDone PUSHJ   last,:CloseImages
	  PUSHJ	    last,:CloseLabels
	  PUT	    :rJ,retaddr
	  POP	    0,0
	  PREFIX    :

	  PREFIX    TestNetworkWithMNIST:
test	  IS	    0
train	  IS	    1
setting	  IS	    test	Temporarily set to TEST since it's a smaller dataset
batchSize IS	    10
retaddr	  IS	    $0
numTotalItems IS    $1
numInBatch IS 	    $2
numCorrect IS	    $3
numAttempted IS	    $4
last	  IS	    $5
:TestNetworkWithMNIST GET retaddr,:rJ
	  SET	    (last+1),setting
	  PUSHJ	    last,:OpenImages
	  SET	    (last+1),setting
	  PUSHJ	    last,:OpenLabels
	  SET	    numTotalItems,last
	  SET	    (last+1),1
	  PUSHJ	    last,:ResetUnits
nextBatch BZ	    numTotalItems,batchesDone
	  SET	    numInBatch,batchSize
nextItem  BZ	    numInBatch,batchDone
	  PUSHJ	    last,:TestSingleImage
	  ZSZ	    :t,last,1
	  ADD	    numCorrect,numCorrect,:t
	  ADD	    numAttempted,numAttempted,1
	  SET	    (last+1),0
	  PUSHJ	    last,:ResetUnits
	  SUB	    numInBatch,numInBatch,1
	  JMP	    nextItem
batchDone SUB	    numTotalItems,numTotalItems,batchSize
	  CMP	    :t,numCorrect,numAttempted
	  STO	    numCorrect,:dmpPtr
	  STO	    numAttempted,:dmpPtr,8
	  SET	    (last+1),1
	  PUSHJ	    last,:ResetUnits
	  JMP	    nextBatch
batchesDone PUSHJ   last,:CloseImages
	  PUSHJ	    last,:CloseLabels
	  PUT	    :rJ,retaddr
	  ADD	    :dmpPtr,:dmpPtr,16
	  POP	    0,0
	  PREFIX    :

	  PREFIX    CreateNetwork:
;	  Creates the structure of a network based off of networkShape
;	  Step 1)   Create all gates
retaddr	  IS   	    $0
networkShape IS	    $1
currLayer IS 	    $2
lastLayer IS 	    $3
unitPtr	  IS	    $4
gatePtr	  IS	    $5
prevOutUnit IS	    $6
prevOutUnitIter IS  $7
firstGate IS  	    $8
inputPtr  IS	    $9
paramPtr  IS	    $10
numLeftInner IS	    $11
numLeftOuter IS	    $12
last	  IS	    $13
:CreateNetwork GET  retaddr,:rJ
	  LDA	    networkShape,:networkShape
	  LDO	    lastLayer,networkShape
	  LDO	    currLayer,networkShape,8
	  ADD	    networkShape,networkShape,8
	  LDA	    prevOutUnit,:Unit_arr	
	  LDA	    gatePtr,:Gate_arr
	  SET	    :t,lastLayer
	  MUL	    :t,:t,:UNIT_SIZE
	  ADD	    unitPtr,prevOutUnit,:t	moves unitPtr just after the last output unit from the input layer
evalNetwork BZ	    currLayer,networkComplete	loops until current layer is 0
	  SET	    numLeftOuter,currLayer	iterate the next loop currLayer number of times
	  SET	    firstGate,gatePtr		record the first gate within this layer
evalLayer BZ	    numLeftOuter,layerComplete	loops through every gate in the layer
	  CREATE_GATE(gatePtr,Gate_arbi_1_fwd,Gate_arbi_1_back)
	  SET	    numLeftInner,lastLayer	iterate the next loop lastLayer number of times
	  SET	    prevOutUnitIter,prevOutUnit	reset prevOutUnitIter back to the first output unit from the previous layer
evalGate  BZ	    numLeftInner,gateComplete	loops through every output unit from the previous layer
	  SET	    (last+1),prevOutUnitIter
	  ADD	    prevOutUnitIter,prevOutUnitIter,:UNIT_SIZE  moves to the next output unit from the previous layer
	  SET	    (last+2),gatePtr
	  PUSHJ	    last,:AttachAsInput		attaches an output unit from the previous layer to the current gate
	  CREATE_PARAMETER(unitPtr,last)
	  SET	    (last+1),unitPtr
	  SET	    (last+2),gatePtr
	  PUSHJ	    last,:AttachAsInput		create a new parameter and attach to the current gate 
	  ADD	    unitPtr,unitPtr,:UNIT_SIZE	move the unitPtr forward since a new unit was created
	  SUB	    numLeftInner,numLeftInner,1
	  JMP	    evalGate
gateComplete SWYM
	  CREATE_PARAMETER(unitPtr,last)
	  SET	    (last+1),unitPtr
	  SET	    (last+2),gatePtr
	  PUSHJ	    last,:AttachAsInput
	  ADD	    unitPtr,unitPtr,:UNIT_SIZE
	  ADD	    gatePtr,gatePtr,:GATE_SIZE
	  SUB	    numLeftOuter,numLeftOuter,1
	  JMP	    evalLayer
layerComplete SET   gatePtr,firstGate
	  SET 	    prevOutUnit,unitPtr
	  SET 	    numLeftOuter,currLayer
1H	  BZ	    numLeftOuter,2F
	  SET	    (last+1),unitPtr
	  SET	    (last+2),gatePtr
	  PUSHJ	    last,:AttachAsOutput
	  ADD	    unitPtr,unitPtr,:UNIT_SIZE
	  ADD	    gatePtr,gatePtr,:GATE_SIZE
	  SUB	    numLeftOuter,numLeftOuter,1
	  JMP	    1B
2H	  LDO	    lastLayer,networkShape
	  LDO	    currLayer,networkShape,8
	  ADD	    networkShape,networkShape,8
	  JMP	    evalNetwork
networkComplete	PUT :rJ,retaddr
	  POP	    0,0
	  PREFIX    :

	  PREFIX    σ:	sigmoid
X	  IS	    $0
retaddr	  IS	    $1
last	  IS	    $2
:σ	  GET	    retaddr,:rJ
	  SET	    (last+1),:e
	  FSUB	    (last+2),:ZERO,X
	  PUSHJ	    last,:pow
	  FADD	    :t,:FONE,last
	  FDIV	    $0,:FONE,:t
	  PUT	    :rJ,retaddr
	  POP	    1,0
	  PREFIX    :

	  PREFIX    pow:
base	  IS	    $0
exp	  IS	    $1
retaddr	  IS	    $2
sqr	  IS	    $3
acc	  IS	    $4
low	  IS	    $5
mid	  IS	    $6
high	  IS	    $7
last	  IS	    $8
:pow	  GET	    retaddr,:rJ
	  BNZ	    exp,1F
	  SET	    $0,:FONE
	  POP	    1,0		PUT instruction not necessary since no subroutine is called.
1H	  FCMP	    :t,exp,:ZERO
	  BNN	    :t,1F		If exp is negative, return 1/(base^-exp) instead
	  SET	    (last+1),base
	  FSUB	    (last+2),:ZERO,exp
	  PUSHJ	    last,:pow
	  FDIV	    $0,:FONE,last
	  PUT	    :rJ,retaddr
	  POP	    1,0
1H	  FCMP	    :t,exp,:FONE
	  BN	    :t,1F
	  SET	    (last+1),base
	  FDIV	    (last+2),exp,:FTWO
	  PUSHJ	    last,:pow
	  FMUL	    $0,last,last
	  PUT	    :rJ,retaddr
	  POP	    1,0
1H	  SET	    low,0
	  SET	    high,:FONE
	  FSQRT	    sqr,base
	  SET	    acc,sqr
	  FDIV	    mid,high,:FTWO
3H	  FEQLE	    :t,mid,exp
	  BNZ	    :t,Done
	  FSQRT	    sqr,sqr
	  FCMP	    :t,mid,exp
	  BNN	    :t,lower
higher	  SET	    low,mid
	  FMUL	    acc,acc,sqr
	  JMP	    2F
lower	  SET	    high,mid
	  FDIV	    :t,:FONE,sqr
	  FMUL	    acc,acc,:t
2H	  FADD	    :t,low,high
	  FDIV	    mid,:t,:FTWO
	  JMP	    3B
Done	  SET	    $0,acc
	  PUT	    :rJ,retaddr
	  POP	    1,0
	  PREFIX    :

	  PREFIX    runTillAllCorrect:
retaddr	  IS	    $0
numCorrect IS	    $1
numTotal  IS	    $2
last	  IS	    $3
:runTillAllCorrect   GET	    retaddr,:rJ
	  SET	    :t,1    initialize to non-zero value
1H	  BZ	    :t,2F   
	  PUSHJ	    last,:Train
	  ADD	    numCorrect,numCorrect,(last+1)
	  ADD	    numTotal,numTotal,last
	  CMP	    :t,(last+1),last
	  JMP	    1B
2H	  PUT	    :rJ,retaddr
finished  SET	    $0,numCorrect
	  SET	    $1,numTotal
	  POP	    2,0
	  PREFIX    :

	  PREFIX    Train:
retaddr	  IS	    $0
currSet	  IS	    $1
currInput IS	    $2
currExpected IS	    $3
numAttempted IS	    $4
numCorrect   IS	    $5
last	     IS	    $10
:Train	  GET  	    retaddr,:rJ
	  LDA	    currSet,:trainingSet	gets address of trainingSet ptr
	  LDO	    currSet,currSet		gets address of trainingSet
	  SET	    numCorrect,0
	  SET	    numAttempted,0
1H	  BZ	    currSet,2F		training complete!
	  LDO	    currInput,currSet,:Y_1
	  LDO	    currExpected,currSet,:Y_2
	  SET	    (last+1),currExpected
	  SET	    (last+2),currInput
	  PUSHJ	    last,:TrainSingle
	  ADD	    numCorrect,numCorrect,last
	  ADD	    numAttempted,numAttempted,1
	  LDO	    currSet,currSet,:LINK
	  JMP	    1B
2H	  PUT	    :rJ,retaddr
	  SET	    $0,numCorrect
	  SET	    $1,numAttempted
	  POP	    2,0
	  PREFIX    :

	  PREFIX    ParameterUpdate:
batchSize IS	    $0
retaddr	  IS	    $1
limit	  IS	    $2
current   IS	    $3
unitVal	  IS	    $4
unitGrad  IS	    $5
last	  IS	    $6
:ParameterUpdate GET retaddr,:rJ
	  SET	    limit,:NUM_UNITS
	  MUL	    limit,limit,:UNIT_SIZE
	  ADD	    limit,limit,:Unit_arr
	  SET  	    current,:Unit_arr
	  FLOT	    batchSize,batchSize
1H	  LDO	    unitVal,current,:IS_PARAM
	  PBZ	    unitVal,2F
	  LDO	    unitGrad,current,:GRAD_SUM
;	  FDIV	    unitGrad,unitGrad,batchSize	take average gradient over each batch
	  FMUL	    unitGrad,unitGrad,:STEP_SIZE
	  LDO	    unitVal,current,:VALUE
	  FADD	    unitVal,unitVal,unitGrad	perform parameter update on a single parameter
	  STO	    unitVal,current,:VALUE	store the new calculated parameter back into VALUE
2H	  ADD	    current,current,:UNIT_SIZE
	  CMP	    :t,current,limit
	  PBN	    :t,1B
	  PUT	    :rJ,retaddr
	  POP	    0,0
	  PREFIX    :

	  PREFIX    AssignGradientBasedOnLabel:
retaddr	  IS	    $0
currUnit  IS	    $1
actualDigit IS	    $2
outputNum IS	    $3
last	  IS	    $4
:AssignGradientBasedOnLabel GET retaddr,:rJ
          LDA	    last,:Unit_arr
	  SET	    outputNum,0
	  SUB	    :t,:NUM_UNITS,:outputLayer
	  MUL	    :t,:t,:UNIT_SIZE
	  ADD	    currUnit,:t,last
	  PUSHJ	    last,:LoadNextLabel
	  SET	    actualDigit,last
2H	  CMP	    :t,outputNum,:outputLayer
	  BZ	    :t,1F
	  CMP	    :t,actualDigit,outputNum
	  BNZ	    :t,incorrectDigit
	  LDO	    :t,currUnit,:VALUE
	  FSUB	    :t,:FONE,:t
	  FMUL	    :t,:FTWO,:t
	  JMP	    3F
incorrectDigit LDO  last,currUnit,:VALUE
	  FSUB	    :t,:ZERO,:FTWO
	  FMUL	    :t,:t,last
3H	  STO	    :t,currUnit,:GRAD
	  ADD	    outputNum,outputNum,1
	  ADD	    currUnit,currUnit,:UNIT_SIZE	    
	  JMP	    2B
1H	  PUT	    :rJ,retaddr
	  POP	    0,0
	  PREFIX    :

	  PREFIX    AcquireNetworkGuess:	0 means no difference between guess and actual
retaddr	  IS	    $0
currUnit  IS	    $1
actualDigit IS	    $2
outputNum IS	    $3
highest	  IS	    $5
highestIndex IS	    $6
last	  IS	    $7
:AcquireNetworkGuess GET retaddr,:rJ
          LDA	    last,:Unit_arr
	  SET	    outputNum,0
	  SUB	    :t,:NUM_UNITS,:outputLayer
	  MUL	    :t,:t,:UNIT_SIZE
	  ADD	    currUnit,:t,last
	  PUSHJ	    last,:LoadNextLabel
	  SET	    actualDigit,last
	  SET	    highest,0
	  SET 	    highestIndex,:NEGONE
2H	  CMP	    :t,outputNum,:outputLayer
	  BZ	    :t,1F
	  LDO	    :t,currUnit,:VALUE
	  FCMP	    last,:t,highest
	  BNP	    last,3F
	  SET	    highestIndex,outputNum
	  SET	    highest,:t
3H	  ADD	    outputNum,outputNum,1
	  ADD	    currUnit,currUnit,:UNIT_SIZE
	  JMP	    2B
1H	  PUT	    :rJ,retaddr
	  CMP	    $0,highestIndex,actualDigit
	  POP	    1,0
	  PREFIX    :

	  PREFIX    LoadImageIntoNetwork:
retaddr	  IS	    $0
limit	  IS	    $1
buffer	  IS	    $2
currPixel IS	    $3
black	  IS	    $4
currUnit  IS	    $5
last	  IS	    $6
:LoadImageIntoNetwork GET retaddr,:rJ
	  LDA	    buffer,:readData
	  LDA	    currUnit,:Unit_arr
	  SET	    currPixel,buffer
	  SETL	    limit,:inputLayer
	  SET	    :t,255
	  FLOT	    black,:t
	  ADD	    limit,limit,buffer
	  SET	    (last+1),buffer
 	  PUSHJ	    last,:LoadNextImage
1H	  CMP	    :t,currPixel,limit
	  BZ	    :t,pixelsDone
	  LDBU	    :t,currPixel
	  FLOT	    :t,:t
	  FDIV	    :t,:t,black
	  STO	    :t,currUnit,:VALUE
	  ADD	    currPixel,currPixel,1
	  ADD	    currUnit,currUnit,:UNIT_SIZE
	  JMP	    1B
pixelsDone PUT	    :rJ,retaddr
	  POP	    0,0
	  PREFIX    :

	  PREFIX    TrainSingle:
;	  Calling Sequence:
;	  SET	    $(X+1),expected
;	  SET	    $(X+2),inputs
;	  PUSHJ	    $(X),:TrainSingle
expected  IS	    $0
inputs	  IS	    $1
retaddr	  IS	    $2
outputs   IS	    $3
limit	  IS   	    $4
current	  IS	    $5
unitVal	  IS	    $6
unitGrad  IS	    $7
guessedCorrect IS   $8
outputUnit IS	    $9
outputVal IS	    $10
half	  IS	    $11
expectedVal IS	    $12
last 	  IS	    $13
tmp	  IS	    last
:TrainSingle  GET    retaddr,:rJ
	  FDIV	    half,:FONE,:FTWO
	  SET       :t,1
	  SUB	    :t,:ZERO,1
;	  Step 1)   clear all units values and gradients (except parameters)
	  SET	    (last+1),0
	  PUSHJ	    last,:ResetUnits
;	  Step 2)   initialize inputs
	  SET  	    current,inputs
2H	  BZ	    current,3F
	  LDO  	    :t,current,:PARAM_UNIT
	  LDO  	    tmp,current,:PARAM_VALUE
	  STO	    tmp,:t,:VALUE
	  LDO	    current,current,:LINK
	  JMP	    2B
;	  Step 3)   Do forward propagation
3H	  PUSHJ	    last,:ForwardProp
;	  Requires redo of logic \/
;	  Step 4)   If data aligns with training set, GRAD = 1, else GRAD = -1
applyGrad LDA  	    outputs,:outputUnits
	  LDO	    outputs,outputs
	  LDO  	    outputUnit,outputs,:INFO
	  LDO  	    expected,expected,:PARAM_VALUE
	  SET	    expectedVal,expected
	  LDO  	    outputVal,outputUnit,:VALUE
	  FCMP	    :t,outputVal,expected
	  FCMP	    tmp,expected,half
	  CMP	    :t,:t,tmp
	  BZ	    :t,1F	If :t and tmp are equal then move on and don't do anything
	  FLOT	    :t,tmp
	  STO	    :t,outputUnit,:GRAD	   Set gradient appropriately
;	  Step 4a)  Determine if the guess was accurate
	  FCMP 	    :t,outputVal,half
	  FCMP	    tmp,expected,half
	  CMP	    guessedCorrect,:t,tmp	0 means correct
;	  Step 5)   Do Backprop
Backprop  PUSHJ	    last,:BackProp
;	  Step 6)   Add addition "spring" pulls
6H	  LDO	    (last+1),:springParams
	  PUSHJ	    last,:SpringPull
;	  Step 7)   Parameter update based off of STEP_SIZE
	  SET	    limit,:NUM_UNITS
	  MUL	    limit,limit,:UNIT_SIZE
	  ADD	    limit,limit,:Unit_arr
	  SET  	    current,:Unit_arr
7H	  LDO	    unitVal,current,:IS_PARAM
	  PBZ	    unitVal,8F
	  LDO	    unitGrad,current,:GRAD
	  FMUL	    unitGrad,unitGrad,:STEP_SIZE
	  LDO	    unitVal,current,:VALUE
	  FADD	    unitVal,unitVal,unitGrad	perform parameter update on a single parameter
	  STO	    unitVal,current,:VALUE	store the new calculated parameter back into VALUE
8H	  ADD	    current,current,:UNIT_SIZE
	  CMP	    :t,current,limit
	  PBN	    :t,7B
1H	  BNZ	    guessedCorrect,1F
	  SET	    $0,1	if guessedCorrect was 0, that means the guess was correct!
	  JMP	    2F
1H	  SET	    $0,0
2H	  PUSHJ	    last,:ForwardProp
	  LDO	    :t,outputUnit,:VALUE
before 	  IS	    outputVal
after	  IS	    :t
	  FCMP	    :t,after,outputVal
improved  FCMP	    :t,expectedVal,outputVal
	  PUT	    :rJ,retaddr
	  POP	    1,0
	  PREFIX    :

	  PREFIX    TrainSingleImage:
;	  Calling Sequence:
;	  SET	    $(X+1),expected
;	  SET	    $(X+2),inputs
;	  PUSHJ	    $(X),:TrainSingle
retaddr	  IS	    $0
limit	  IS   	    $1
current	  IS	    $2
unitVal	  IS	    $3
unitGrad  IS	    $4
last 	  IS	    $5
tmp	  IS	    last
:TrainSingleImage  GET    retaddr,:rJ
;	  Step 1)   clear all units values and gradients (except parameters)
	  SET  	    (last+1),0
	  PUSHJ	    last,:ResetUnits
;	  Step 2)   initialize inputs
	  PUSHJ	    last,:LoadImageIntoNetwork
;	  Step 3)   Do forward propagation
3H	  PUSHJ	    last,:ForwardProp
;	  Step 4)   Set the gradient appropriately
	  PUSHJ	    last,:AssignGradientBasedOnLabel
;	  Step 5)   Do Backprop
	  PUSHJ	    last,:BackProp
	  PUT	    :rJ,retaddr
	  POP	    0,0
	  PREFIX    :

	  PREFIX    TestSingleImage:
;	  Calling Sequence:
;	  SET	    $(X+1),expected
;	  SET	    $(X+2),inputs
;	  PUSHJ	    $(X),:TrainSingle
retaddr	  IS	    $0
limit	  IS   	    $1
current	  IS	    $2
unitVal	  IS	    $3
unitGrad  IS	    $4
last 	  IS	    $5
tmp	  IS	    last
:TestSingleImage  GET    retaddr,:rJ
;	  Step 1)   clear all units values and gradients (except parameters)
	  SET  	    (last+1),0
	  PUSHJ	    last,:ResetUnits
;	  Step 2)   initialize inputs
	  PUSHJ	    last,:LoadImageIntoNetwork
;	  Step 3)   Do forward propagation
3H	  PUSHJ	    last,:ForwardProp
;	  Step 4)   Determind the network's guess
	  PUSHJ	    last,:AcquireNetworkGuess
	  PUT	    :rJ,retaddr
	  SET	    $0,last
	  POP	    1,0
	  PREFIX    :

	  PREFIX    SpringPull:
;	  Calling Sequence:
;	  PUSHJ	    $(X),:SpringPull
current   IS	    $0
unitPtr	  IS	    $1
flotNegOne IS	    $2
tmp	  IS	    $3
:SpringPull  LDA    :t,:springParams
	  LDO	    current,:t
	  FLOT	    flotNegOne,:NEGONE
1H	  BZ	    current,2F
	  LDO	    unitPtr,current,:INFO
	  LDO	    tmp,unitPtr,:GRAD
	  LDO	    :t,unitPtr,:VALUE
	  FMUL	    :t,:t,flotNegOne	t <- Unit_Value*-1
	  FADD	    :t,tmp,:t
	  STO	    :t,unitPtr,:GRAD	GRAD -= VALUE
	  LDO	    current,current,:LINK
	  JMP	    1B
2H	  POP	    0,0
	  PREFIX    :

	  PREFIX    ResetUnits:
isFullRst IS	    $0		0 indicates: GRAD_SUM+=GRAD and reset GRAD
;	  	    		1 indicates: reset GRAD_SUM and GRAD
unitPtr	  IS	    $1
maxUnit	  IS	    $2
isParam	  IS	    $3
last	  IS	    $4
:ResetUnits SET	    unitPtr,:Unit_arr
	  SET	    :t,:UNIT_SIZE
	  MUL	    :t,:t,:NUM_UNITS
	  ADD	    maxUnit,:t,:Unit_arr
1H	  BZ	    isFullRst,3F
	  STO	    :ZERO,unitPtr,:GRAD
	  STO	    :ZERO,unitPtr,:GRAD_SUM
	  JMP	    2F
3H	  LDO	    :t,unitPtr,:GRAD
	  LDO	    last,unitPtr,:GRAD_SUM
	  FADD	    :t,last,:t
	  STO	    :t,unitPtr,:GRAD_SUM
2H	  STO	    :ZERO,unitPtr,:GRAD
	  ADD	    unitPtr,unitPtr,:UNIT_SIZE
	  CMP	    :t,unitPtr,maxUnit
	  PBN	    :t,1B
	  POP	    0,0
	  PREFIX    :

	  PREFIX    ForwardProp:
;	  Calling Sequence:
;	  PUSHJ	    $(X),:ForwardProp
retaddr	  IS	    $0
gateIndex IS	    $1
gatePtr	  IS	    $3
fptr	  IS	    $4
outputPtr IS	    $5
count 	  IS	    $6
retval	  IS	    $7
:ForwardProp GET    retaddr,:rJ
	  SET	    gateIndex,0
	  SET	    count,0
	  SET	    outputPtr,:TopOutput
1H	  LDO	    :t,outputPtr	load the next gate in topological ordering
	  SUB	    :t,:t,1
	  MUL	    gateIndex,:t,:GATE_SIZE
	  LDA	    gatePtr,:Gate_arr,gateIndex    get address of gate
	  LDO	    fptr,gatePtr,:FWD_PTR
	  SET	    (retval+1),gatePtr
	  PUSHGO    retval,fptr
	  ADD	    outputPtr,outputPtr,8
	  ADD	    count,count,1
	  CMP	    :t,count,:NUM_GATES
	  PBN	    :t,1B
	  PUT	    :rJ,retaddr
	  POP	    0,0
	  PREFIX    :

	  PREFIX    BackProp:
;	  Calling Sequence:
;	  PUSHJ	    $(X),:BackProp
retaddr	  IS	    $0
gateIndex IS	    $1
gatePtr	  IS	    $3
fptr	  IS	    $4
outputPtr IS	    $5
count 	  IS	    $6
retval	  IS	    $7
:BackProp GET	    retaddr,:rJ
	  SET	    gateIndex,0
	  SET	    count,0
	  SUB	    :t,:NUM_GATES,1
	  MUL	    :t,:t,8
	  ADD	    outputPtr,:t,:TopOutput	initialize outputPtr to the last gate in topological order
1H	  LDO	    :t,outputPtr	load the next gate in topological ordering
	  SUB	    :t,:t,1
	  MUL	    gateIndex,:t,:GATE_SIZE
	  LDA	    gatePtr,:Gate_arr,gateIndex    get address of gate
	  LDO	    fptr,gatePtr,:BACK_PTR
	  SET	    (retval+1),gatePtr
	  PUSHGO    retval,fptr
	  SUB	    outputPtr,outputPtr,8
	  ADD	    count,count,1
	  CMP	    :t,count,:NUM_GATES
	  PBN	    :t,1B
	  PUT	    :rJ,retaddr
	  POP	    0,0
	  PREFIX    :

	  PREFIX    TopSort:
;	  Calling Sequence:
;	  PUSHJ	    $(X),:TopSort
N	  IS	    $0
retaddr	  IS	    $1
kk	  IS	    $2
NN	  IS	    $3
P	  IS	    $4
F	  IS	    $5
R	  IS	    $6
TopOutput IS	    $7
last	  IS	    $10
:TopSort  GET	    retaddr,:rJ
	  SET	    TopOutput,:TopOutput
	  PUSHJ	    (last+1),:LoadInput
	  ADD	    N,(last+1),0	Assign N
;	  T4.	    [Scan for Zeros.]
	  SET	    :t,0
	  SL	    NN,N,4
	  SET	    R,0 		R ← 0
	  STO	    :ZERO,:QLINK,0    	QLINK[0] ← 0
	  SET	    kk,16
1H	  LDO	    :t,:COUNT,kk
	  BZ	    :t,3F
2H	  ADD	    kk,kk,16
	  CMP	    :t,kk,NN
	  BP	    :t,4F
	  JMP	    1B
3H	  SR	    last,kk,4
	  SL	    :t,R,4
	  STO	    last,:QLINK,:t
	  SET	    R,last
	  JMP	    2B
4H	  LDO	    F,:QLINK
;	  T5.	    [Output front of queue.]
9H	  CMP	    :t,F,:NUM_GATES
	  BP	    :t,Ignored	  
	  STO	    F,TopOutput
	  ADD	    TopOutput,TopOutput,8
Ignored	  BZ	    F,8F
	  SUB	    N,N,1
	  SL	    :t,F,4		Convert F to a byte offset
	  LDO	    P,:TOP,:t		P ← TOP[F]
;	  T6.	    [Erase relations.]
6H	  BZ	    P,7F
	  LDO	    :t,P,:INFO		:t ← SUC(P)
	  SL	    :t,:t,4		:t ← SUC(P) (as byte offset)
	  LDO	    last,:COUNT,:t
	  SUB	    last,last,1
	  STO	    last,:COUNT,:t	Decrement COUNT[SUC(P)]
	  BNZ	    last,5F
	  SL	    :t,R,4		:t ← R (as byte offset)
	  LDO	    last,P,:INFO 	last ← SUB(P)
	  STO	    last,:QLINK,:t	QLINK[R] ← SUC(P)
	  SET	    R,last		R ← SUC(P)
5H	  LDO	    P,P,:LINK		P ← NEXT(P)
	  JMP	    6B
;	  T7.	    [Remove from queue.]
7H	  SL	    last,F,4
	  LDO	    F,:QLINK,last
	  JMP	    9B
;	  T8.	    [End of process.]
8H	  BZ	    N,1F
	  TRAP	    0,:Halt,0	Error Topological Ordering not achieved. 
1H	  PUT	    :rJ,retaddr
	  POP	    0,0
	  PREFIX    :

	  PREFIX    LoadInput:
;	  Calling Sequence:
;	  PUSHJ	    $(X),:LoadInput
;	  Returns N
N	  IS	    $0
NumGates  IS	    $0
NumUnits  IS	    $1
retaddr	  IS	    $2
flag	  IS	    $3
arg1	  IS	    $4
arg2	  IS	    $5
arg3	  IS	    $6
arg4	  IS	    $7
j	  IS	    $8
k	  IS	    $9
jj	  IS	    $10
kk	  IS	    $12
last	  IS	    $13
:LoadInput GET	    retaddr,:rJ
	  SET	    NumGates,:NUM_GATES
	  SET	    NumUnits,:NUM_UNITS
	  SET	    flag,0
	  SET	    arg1,NumGates
	  SET	    arg2,0
	  LDO	    :t,:Gate_arr,:OUT_UNIT
	  LDO	    arg3,:t,:IN_GATES	Loads the pointer to the in_gates first element
3H	  CMP	    :t,flag,0
	  SET	    (last+1),arg1
	  SET	    (last+2),arg2
	  SET	    (last+3),arg3
	  SET	    (last+4),arg4
	  PBZ	    :t,4F
	  PUSHJ	    last,:ReadPairUnit
	  JMP	    5F
4H	  PUSHJ	    last,:ReadPairGate          Passes in: *,arg1,arg2,arg3,arg4,*
5H	  SET	    j,(last+5)			returns  : k,arg1,arg2,arg3,arg4,j
	  SET	    k,last
	  SET	    arg1,(last+1)
	  SET	    arg2,(last+2)
	  SET	    arg3,(last+3)
	  SET	    arg4,(last+4)
	  CMP	    :t,j,k
	  PBNZ	    :t,1F
	  PBZ	    j,2F	change back to 2F after debugging!
	  TRAP	    0,:Halt,0	Cycle detected. j≺j
1H	  SL	    jj,j,4
	  SL	    kk,k,4
	  LDO	    :t,:COUNT,kk
	  ADD	    :t,:t,1
	  STO	    :t,:COUNT,kk	COUNT[k] ← COUNT[k]+1
	  SET	    (last+1),k
	  LDA	    (last+2),:TOP,jj
	  PUSHJ	    (last+0),:Push
	  JMP	    3B
2H	  BNZ	    flag,6F
	  SET	    flag,1
	  SET	    arg1,NumUnits
	  SET	    arg2,0	index of unit array
	  LDO	    arg3,:Unit_arr,:IN_GATES	Loads the first gate that Unit[0] precedes
	  ADD	    arg4,NumGates,1		Make sure the inputs continue where gates left off
	  JMP 	    3B
6H	  SUB	    $0,arg4,1
	  PUT	    :rJ,retaddr
	  POP	    1,0
	  PREFIX    :

	  PREFIX    ReadPairGate:
numGates  IS	    $0
gateIndex IS	    $1
in_gates  IS	    $2
j	  IS	    $4
k	  IS	    $5
out_gate  IS	    $6
:ReadPairGate PBNZ  in_gates,1F		check if in_gates is null
	  ADD	    gateIndex,gateIndex,:GATE_SIZE	move gateIndex forward 1 gate
	  DIV	    :t,gateIndex,:GATE_SIZE
	  CMP	    :t,:t,numGates
	  PBN	    :t,2F		check if gateIndex is still in range
	  SET	    j,0			if it isn't, return 0,0
	  SET	    k,0
	  POP	    6,0
2H	  LDA	    :t,:Gate_arr,gateIndex
	  LDO	    :t,:t,:OUT_UNIT	get the unit who is the output to the current gate
	  LDO	    in_gates,:t,:IN_GATES   load the ptr to the first of in_gates
	  JMP	    :ReadPairGate
1H	  DIV	    :t,gateIndex,:GATE_SIZE
	  ADD	    j,:t,1		get the value of j
	  LDO	    :t,in_gates,:INFO	get the address of gate k
	  SUB	    :t,:t,:Gate_arr
	  DIV	    :t,:t,:GATE_SIZE
	  ADD	    k,:t,1
	  LDO	    in_gates,in_gates,:LINK
	  POP	    6,0
	  PREFIX    :

	  PREFIX    ReadPairUnit:
numUnits  IS	    $0
unitIndex IS	    $1
in_gates  IS	    $2
unitNum	  IS	    $3
j	  IS	    $4
k	  IS	    $5
:ReadPairUnit SET   j,0
	  SET	    k,0
	  POP	    6,0		No more input units
	  LDA   :t,:Unit_arr,unitIndex
	  LDO 	    :t,:t,:OUT_GATE
	  BNZ  	    :t,FIX		check if out_gate is null
	  BZ	    in_gates,FIX	check if in_gates is null
	  SET	    j,unitNum		get the value of j
	  LDO	    :t,in_gates,:INFO	get the address of gate k
	  SUB	    :t,:t,:Gate_arr
	  DIV	    :t,:t,:GATE_SIZE
	  ADD	    k,:t,1		get the value of k
	  LDO	    in_gates,in_gates,:LINK 	move in_gates to the next gate
	  	    ;check if in_gates is now null, if it is increment unitNum
	  BNZ	    in_gates,1F
	  ADD	    unitNum,unitNum,1
1H	  POP	    6,0
FIX	  ADD	    unitIndex,unitIndex,:UNIT_SIZE
	  DIV	    :t,unitIndex,:UNIT_SIZE
	  CMP	    :t,:t,numUnits
	  PBN	    :t,IN_RANGE
	  SET	    j,0
	  SET	    k,0
	  POP	    6,0		No more input units
IN_RANGE  LDA	    :t,:Unit_arr,unitIndex
	  LDO	    in_gates,:t,:IN_GATES   load the ptr to the first of in_gates
	  JMP	    :ReadPairUnit
	  PREFIX    :

	  PREFIX    Gate_arbi_1_fwd:
;	  Input format: ax+by+cz+...+offset in reverse order. Always assumes an odd number of inputs
;	  Reads offset, adds to accumulator
;	  Reads both c and z, multiplies and adds to accumulator
;	  Repeates on all remaining elements 2 at a time until none left
;	  Computes sigmoid on the accumulator
Gate	  IS	    $0
retaddr	  IS	    $1
acc	  IS	    $2	accumulates the expression
currUnit  IS	    $3
param	  IS	    $4
var	  IS	    $5
last	  IS	    $10
tmp	  IS	    last
:Gate_arbi_1_fwd	GET retaddr,:rJ
	  LDO	    currUnit,Gate,:IN_UNITS  loads head of in_units
	  LDO	    :t,currUnit,:INFO
	  LDO	    acc,:t,:VALUE
	  LDO	    tmp,:t,:IS_PARAM
	  BZ	    tmp,error
	  LDO	    currUnit,currUnit,:LINK
nextPair  BZ	    currUnit,sumDone
	  LDO	    :t,currUnit,:INFO
	  LDO	    param,:t,:VALUE
	  LDO	    tmp,:t,:IS_PARAM
	  BZ	    tmp,error
	  LDO	    currUnit,currUnit,:LINK
	  LDO	    :t,currUnit,:INFO
	  LDO	    var,:t,:VALUE
	  LDO	    tmp,:t,:IS_PARAM
	  BNZ	    tmp,error
	  LDO	    currUnit,currUnit,:LINK
	  FMUL	    :t,param,var
	  FADD	    acc,acc,:t		acc+=a*x where a is a parameter and x is a variable
	  JMP	    nextPair
sumDone	  SET	    (last+1),acc
	  PUSHJ	    last,:σ
	  LDO	    :t,Gate,:OUT_UNIT
	  STO	    last,:t,:VALUE
	  PUT  	    :rJ,retaddr
	  POP	    0,0
error	  TRAP	    0,:Halt,0	unit is/isn't parameter when it should/shouldn't be
	  PREFIX    :

	  PREFIX    Gate_arbi_1_back:
;	  Input format: ax+by+cz+...+offset in reverse order. Always assumes an odd number of inputs
;	  Reads offset, adds σ(...)*(1-σ(...)) to gradient
;	  Reads both c and z, adds σ(...)*(1-σ(...))*z to gradient of c and σ(...)*(1-σ(...))*c to gradient of z
;	  Repeates on all remaining elements 2 at a time until none left
Gate	  IS	    $0
retaddr	  IS	    $1
currUnit  IS	    $2
currUnitPtr IS	    $3
s	  IS	    $4  output of sigmoid function
ds	  IS	    $5
param	  IS	    $6	parameter such as a,b,c
var	  IS	    $7  variable such as x,y,z
dparam	  IS	    $8	parameter such as a,b,c
dvar	  IS	    $9  variable such as x,y,z
paramPtr  IS	    $10
varPtr	  IS	    $11
inGrad	  IS	    $12
last	  IS	    $13
:Gate_arbi_1_back	GET retaddr,:rJ
	  LDO	    :t,Gate,:OUT_UNIT
	  LDO	    s,:t,:VALUE		computes σ(ax+by+cz+...+offset)
	  LDO	    inGrad,:t,:GRAD		incoming gradient
	  FSUB	    :t,:FONE,s
	  FMUL	    ds,:t,s
	  FMUL	    ds,ds,inGrad	        computes σ(...)*(1-σ(...))*incoming gradient
	  LDO	    currUnit,Gate,:IN_UNITS  loads head of in_units
	  LDO	    currUnitPtr,currUnit,:INFO
	  LDO	    :t,currUnitPtr,:GRAD		load current gradient
	  FADD	    :t,:t,ds
	  STO	    :t,currUnitPtr,:GRAD	offset.grad+=ds
	  LDO	    currUnit,currUnit,:LINK
nextPair  BZ	    currUnit,sumDone
	  LDO	    varPtr,currUnit,:INFO
	  LDO	    var,varPtr,:VALUE
	  LDO	    currUnit,currUnit,:LINK
	  LDO	    paramPtr,currUnit,:INFO
	  LDO	    param,paramPtr,:VALUE
	  LDO	    currUnit,currUnit,:LINK
	  LDO	    :t,varPtr,:GRAD
	  FMUL	    dvar,param,ds
	  FADD	    :t,dvar,:t		var.grad+=param.value*ds
	  STO	    :t,varPtr,:GRAD
	  LDO	    :t,paramPtr,:GRAD
	  FMUL	    dparam,var,ds
	  FADD	    :t,dparam,:t		param.grad+=var.value*ds
	  STO	    :t,paramPtr,:GRAD
	  JMP	    nextPair
sumDone	  PUT  	    :rJ,retaddr
	  POP	    0,0
	  PREFIX    :

	  PREFIX    Gate_Addition_2_fwd:
Gate	  IS	    $0
a	  IS	    $1
b	  IS	    $2
tmp	  IS	    $3
:Gate_Addition_2_fwd	LDO   tmp,Gate,:IN_UNITS  loads head of in_units
	  LDO	    :t,tmp,:INFO     loads ptr to in unit
	  LDO	    a,:t,:VALUE	     loads value of in unit
	  LDO	    tmp,tmp,:LINK    loads next of in_units
	  LDO	    :t,tmp,:INFO     loads ptr to in unit
	  LDO	    b,:t,:VALUE	     loads value of in unit
	  FADD	    tmp,a,b	     calculates out unit value
	  LDO	    :t,Gate,:OUT_UNIT   loads ptr to out unit
	  STO	    tmp,:t,:VALUE    stores a+b to out unit value 
	  POP	    0,0
	  PREFIX    :

	  PREFIX    Gate_Addition_2_back:
	  ; f(x)=a+b
	  ; da=1*dx
	  ; db=1*dx
Gate	  IS	    $0
unit_a	  IS	    $1
unit_b	  IS	    $2
dx	  IS	    $3
floatOne  IS	    $4
da	  IS	    $5
db	  IS	    $6
tmp	  IS	    $7
:Gate_Addition_2_back SET floatOne,1
	  FLOT	    floatOne,floatOne
	  LDO	    tmp,Gate,:OUT_UNIT
	  LDO	    dx,tmp,:GRAD		load dx
	  LDO       tmp,Gate,:IN_UNITS  	loads head of in_units
          LDO	    unit_a,tmp,:INFO
	  LDO	    tmp,tmp,:LINK
          LDO	    unit_b,tmp,:INFO
	  LDO	    tmp,unit_a,:GRAD
	  FMUL	    da,floatOne,dx
	  FADD	    tmp,tmp,da
	  STO	    tmp,unit_a,:GRAD
	  LDO	    tmp,unit_b,:GRAD
	  FMUL	    db,floatOne,dx
	  FADD	    tmp,tmp,db
	  STO	    tmp,unit_b,:GRAD
	  POP	    0,0
	  PREFIX    :

	  PREFIX    Gate_Multiplication_2_fwd:
Gate	  IS	    $0
a	  IS	    $1
b	  IS	    $2
tmp	  IS	    $3
:Gate_Multiplication_2_fwd	LDO   tmp,Gate,:IN_UNITS  loads head of in_units
	  LDO	    :t,tmp,:INFO     loads ptr to in unit
	  LDO	    a,:t,:VALUE	     loads value of in unit
	  LDO	    tmp,tmp,:LINK    loads next of in_units
	  LDO	    :t,tmp,:INFO     loads ptr to in unit
	  LDO	    b,:t,:VALUE	     loads value of in unit
	  FMUL	    tmp,a,b	     calculates out unit value
	  LDO	    :t,Gate,:OUT_UNIT   loads ptr to out unit
	  STO	    tmp,:t,:VALUE    stores a+b to out unit value 
	  POP	    0,0
	  PREFIX    :

	  PREFIX    Gate_Multiplication_2_back:
	  ; f(x)=a*b
	  ; da=b*dx
	  ; db=a*dx
Gate	  IS	    $0
unit_a	  IS	    $1
unit_b	  IS	    $2
a	  IS	    $3
b	  IS	    $4
dx	  IS	    $5
floatOne  IS	    $6
da	  IS	    $7
db	  IS	    $8
tmp	  IS	    $9
:Gate_Multiplication_2_back LDO	    tmp,Gate,:OUT_UNIT
          LDO	    dx,tmp,:GRAD		load dx
          LDO       tmp,Gate,:IN_UNITS  	loads head of in_units
          LDO	    unit_a,tmp,:INFO
          LDO	    a,unit_a,:VALUE
          LDO	    tmp,tmp,:LINK
          LDO	    unit_b,tmp,:INFO
          LDO	    b,unit_b,:VALUE
          LDO	    tmp,unit_a,:GRAD
          FMUL	    da,b,dx
          FADD	    tmp,tmp,da
          STO	    tmp,unit_a,:GRAD
          LDO	    tmp,unit_b,:GRAD
          FMUL	    db,a,dx
          FADD	    tmp,tmp,db
          STO	    tmp,unit_b,:GRAD
          POP	    0,0
          PREFIX    :

	  PREFIX    AttachAsInput:
Unit	  IS	    $0
Gate	  IS	    $1
retaddr	  IS	    $2
retval	  IS	    $3
:AttachAsInput GET  retaddr,:rJ
          SET  	    (retval+1),Gate
          ADD	    (retval+2),Unit,:IN_GATES
          PUSHJ	    retval,:Push
          SET  	    (retval+1),Unit
          ADD	    (retval+2),Gate,:IN_UNITS
          PUSHJ	    retval,:Push
          PUT	    :rJ,retaddr
          POP	    0,0
          PREFIX    :

	  PREFIX    AttachAsOutput:
Unit	  IS	    $0
Gate	  IS	    $1
retaddr	  IS	    $2
retval	  IS	    $3
:AttachAsOutput     STO	    Unit,Gate,:OUT_UNIT
          STO	    Gate,Unit,:OUT_GATE
          POP	    0,0
          PREFIX    :

	  PREFIX    Push:
; 	  Calling Sequence:
;	  SET	    $(X+1),Y	Data
;	  SET	    $(X+2),T    Pointer to address that contains the TOP pointer
;	  PUSHJ	    $(X),:Push		
Y	  IS	    $0
T	  IS	    $1
retaddr	  IS	    $2
P	  IS	    $3
:Push	  GET	    retaddr,:rJ
          PUSHJ	    P,:Alloc    P ⇐ AVAIL
          STO	    Y,P,:INFO    INFO(P) ← Y (offset of 8 is specific data format)
          LDO	    :t,T,:LINK	
          STO	    :t,P,:LINK	LINK(P) ← T
          STO	    P,T,:LINK	T ← P
          PUT	    :rJ,retaddr
          POP	    0,0
          PREFIX    :

	  PREFIX    PushArbi:
; 	  Calling Sequence:
;	  SET	    $(X+1),NumBytes	number of octabytes being pushed
;	  SET	    $(X+2),T    Pointer to address that contains the TOP pointer
;	  PUSHJ	    $(X),:PushArbi		
NumBytes  IS	    $0
T	  IS	    $1
retaddr	  IS	    $2
P	  IS	    $3
:PushArbi GET	    retaddr,:rJ
	  SET	    (P+1),NumBytes
          PUSHJ	    P,:AllocArbi    P ⇐ AVAIL
          LDO	    :t,T,:LINK	
          STO	    :t,P,:LINK	LINK(P) ← T
          STO	    P,T,:LINK	T ← P
	  SET	    $0,P
          PUT	    :rJ,retaddr
          POP	    1,0
          PREFIX    :

	  PREFIX    Push_2:
; 	  Calling Sequence:
;	  SET	    $(X+1),nothing
;	  SET	    $(X+2),T    Pointer to address that contains the TOP pointer
;	  PUSHJ	    $(X),:PushArbi		
NumBytes  IS	    $0
T	  IS	    $1
retaddr	  IS	    $2
P	  IS	    $3
:Push_2 GET	    retaddr,:rJ
          PUSHJ	    P,:Alloc_2    P ⇐ AVAIL
          LDO	    :t,T,:LINK	
          STO	    :t,P,:LINK	LINK(P) ← T
          STO	    P,T,:LINK	T ← P
	  SET	    $0,P
          PUT	    :rJ,retaddr
          POP	    1,0
          PREFIX    :

          PREFIX    Pop:
; 	  Calling Sequence:
;	  SET	    $(X+1),T    Pointer to address that contains the TOP pointer
;	  PUSHJ	    $(X),:Pop
T	  IS	    $0
retaddr	  IS	    $1
Y	  IS	    $2
P	  IS	    $3
:Pop	  GET	    retaddr,:rJ
          LDO	    :t,T,:LINK
          PBNZ	    :t,1F	If T = Λ
          TRAP	    0,:Halt,0	Error: Underflow!
1H	  LDO	    P,T,:LINK	P ← T
          LDO	    :t,P,:LINK
          STO	    :t,T,:LINK	T ← LINK(P)
          LDO	    Y,P,:INFO	Y ← INFO(P)
          SET	    $5,P
          PUSHJ	    $4,:Dealloc
          SET	    $0,Y
          PUT	    :rJ,retaddr
          POP	    1,0
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

          PREFIX    Alloc_2:
X	  IS	    $0
:Alloc_2  PBNZ	    :AVAIL_2,1F
          SET	    X,:POOLMAX_2
          ADD	    :POOLMAX_2,X,:c_2
          CMP	    :t,:POOLMAX_2,:SEQMIN_2
          PBNP	    :t,2F
          TRAP	    0,:Halt,0        Overflow (no nodes left)_2
1H	  SET	    X,:AVAIL_2
          LDO	    :AVAIL_2,:AVAIL_2,:LINK
2H	  POP	    1,0
          PREFIX    :

          PREFIX    AllocArbi:
size	  IS	    $0	size of data in octabytes
X	  IS	    $1
:AllocArbi PBNZ	    :AVAIL,1F
          SET	    X,:POOLMAX
	  ADD	    size,size,1
	  SL	    :t,size,3
          ADD	    :POOLMAX,X,:t
          CMP	    :t,:POOLMAX,:SEQMIN
          PBNP	    :t,2F
          TRAP	    0,:Halt,0        Overflow (no nodes left)
1H	  SET	    X,:AVAIL
          LDO	    :AVAIL,:AVAIL,:LINK
2H	  SET	    $0,X
	  POP	    1,0
          PREFIX    :

	  PREFIX    Dealloc:
;	  Doesn't check if trying to dealloc a node that was never alloc'd	  
X	  IS	    $0
:Dealloc  STO	    :AVAIL,X,:LINK
1H	  SET	    :AVAIL,X
          POP	    0,0
          PREFIX    :

	  PREFIX    OpenImages:
isTrain	  IS	    $0		0 means test set, 1 means training set
charPtr	  IS	    $1
numBytes  IS	    $2
freadAddr IS	    $3
readData  IS	    $4
tmp	  IS	    $5
:OpenImages BZ	    isTrain,test
train	  LDA	    charPtr,:train_images
	  JMP	    1F
test	  LDA	    charPtr,:test_images
1H	  LDA	    :t,:fopenArgs
	  STO	    charPtr,:t
	  LDA	    $255,:fopenArgs;	TRAP  0,:Fopen,:imageHandle
	  BN	    $255,failed
;	  Read the magic number to verify it is the correct file.
2H	  SET  	    numBytes,4
	  LDA	    freadAddr,:freadArgs
	  STO	    numBytes,freadAddr,8
	  LDA	    $255,:freadArgs;	TRAP  0,:Fread,:imageHandle
	  BN	    $255,failed
	  LDA	    readData,:readData
	  LDT	    :t,readData		Reads file's magic number
	  LDA	    tmp,:images_magic
	  LDT	    tmp,tmp		Reads correct magic number
	  CMP	    :t,:t,tmp
	  BNZ	    :t,failedMagic
	  LDA	    $255,:freadArgs;	TRAP  0,:Fread,:imageHandle
	  BN	    $255,failed
	  LDT	    $0,readData		Reads the number of images in file
	  LDA	    $255,:freadArgs;	TRAP  0,:Fread,:imageHandle
	  BN	    $255,failed		skips over number of rows
	  LDA	    $255,:freadArgs;	TRAP  0,:Fread,:imageHandle
	  BN	    $255,failed		skips over number of columns
;	  SET	    $0,100
	  POP	    1,0
failedMagic TRAP    0,:Halt,0	Wrong magic number!
failed	  TRAP	    0,:Halt,0	Unable to open file!
	  PREFIX    :

	  PREFIX    CloseImages:
:CloseImages TRAP   0,:Fclose,:imageHandle
	  POP	    0,0
	  PREFIX    :

	  PREFIX    CloseLabels:
:CloseLabels TRAP   0,:Fclose,:labelHandle
	  POP	    0,0
	  PREFIX    :

	  PREFIX    OpenLabels:
isTrain	  IS	    $0		0 means test set, 1 means training set
charPtr	  IS	    $1
numBytes  IS	    $2
freadAddr IS	    $3
readData  IS	    $4
tmp	  IS	    $5
:OpenLabels BZ	    isTrain,test
train	  LDA	    charPtr,:train_labels
	  JMP	    1F
test	  LDA	    charPtr,:test_labels
1H	  LDA	    :t,:fopenArgs
	  STO	    charPtr,:t
	  LDA	    $255,:fopenArgs;	TRAP  0,:Fopen,:labelHandle
	  BN	    $255,failed
;	  Read the magic number to verify it is the correct file.
2H	  SET  	    numBytes,4
	  LDA	    freadAddr,:freadArgs
	  STO	    numBytes,freadAddr,8
	  LDA	    $255,:freadArgs;	TRAP  0,:Fread,:labelHandle
	  BN	    $255,failed
	  LDA	    readData,:readData
	  LDT	    :t,readData		Reads file's magic number
	  LDA	    tmp,:labels_magic
	  LDT	    tmp,tmp		Reads correct magic number
	  CMP	    :t,:t,tmp
	  BNZ	    :t,failedMagic
	  LDA	    $255,:freadArgs;	TRAP  0,:Fread,:labelHandle
	  BN	    $255,failed
	  LDT	    $0,readData		Reads the number of labels in file
;	  SET	    $0,100
	  POP	    1,0
failedMagic TRAP    0,:Halt,0	Wrong magic number!
failed	  TRAP	    0,:Halt,0	Unable to open file!
	  PREFIX    :

	  PREFIX    LoadNextImage:
buffer	  IS	    $0
freadAddr IS	    $1
:LoadNextImage LDA  freadAddr,:freadArgs
	  TRAP 	    0,:Ftell,:imageHandle
	  SETL 	    :t,28*28
	  STO	    :t,freadAddr,8
	  LDA	    $255,:freadArgs;	TRAP  0,:Fread,:imageHandle
	  BN	    $255,failed		skips over number of rows
Done	  POP	    0,0
failed	  TRAP	    0,:Halt,0	Unable to read file!
	  PREFIX    :

	  PREFIX    LoadNextLabel:
freadAddr IS	    $0
:LoadNextLabel LDA  freadAddr,:freadArgs
	  TRAP 	    0,:Ftell,:labelHandle
	  SETL 	    :t,1
	  STO	    :t,freadAddr,8
	  LDA	    $255,:freadArgs;	TRAP  0,:Fread,:labelHandle
	  BN	    $255,failed		skips over number of rows
Done	  LDA	    :t,:readData
	  LDBU	    $0,:t
	  POP	    1,0
failed	  TRAP	    0,:Halt,0	Unable to read file!
	  PREFIX    :

	  PREFIX    rand:
X	  IS	    $0
a	  IS	    $1
c	  IS	    $2
last	  IS	    $3
:rand	  GETA	    last,X_
	  LDO	    X,last
	  GETA	    :t,a_
	  LDO	    a,:t
	  GETA	    :t,c_
	  LDO	    c,:t
	  MUL	    :t,a,X
	  ADD	    X,:t,c
	  STO	    X,last
	  FLOT	    X,X
	  SET	    :t,:NEGONE
	  ANDNH	    :t,#8000
	  FLOT	    :t,:t
	  FDIV	    X,X,:t
	  POP	    1,0
a_	  OCTA	    #5851F42D4C957F2D
c_	  OCTA	    #14057B7EF767814F
X_	  OCTA	    :seed
	  PREFIX    :

	  PREFIX    CountInputs:
count 	  IS	    $0
tmp	  IS	    $1
ptr	  IS	    $2
:CountInputs LDA    ptr,:Gate_arr
	  LDA	    tmp,:Unit_arr
	  SET	    count,0
3H	  CMP	    :t,ptr,tmp
	  BNZ	    :t,4F
	  POP	    0,0
4H	  SET	    :t,ptr
1H	  LDO	    :t,:t,:LINK
	  BNZ	    :t,2F
	  JMP	    nextGate
2H	  ADD	    count,count,1
	  JMP	    1B
nextGate  SET	    :t,count
	  SET	    count,0
	  ADD	    ptr,ptr,:GATE_SIZE
	  JMP	    3B
	  PREFIX    :

	  PREFIX    CountInputs1:
count 	  IS	    $0
tmp	  IS	    $1
ptr	  IS	    $2
:CountInputs1 LDA   ptr,:Unit_arr
	  ADD 	    ptr,ptr,:IN_GATES
	  LDA	    tmp,:COUNT
	  SET	    count,0
3H	  CMP	    :t,ptr,tmp
	  PBN	    :t,4F
	  POP	    0,0
4H	  SET	    :t,ptr
1H	  LDO	    :t,:t,:LINK
	  BNZ	    :t,2F
	  JMP	    nextUnit
2H	  ADD	    count,count,1
	  JMP	    1B
nextUnit  SET	    :t,count
;	  STO	    count,:dmpPtr
;	  ADD	    :dmpPtr,:dmpPtr,8
	  SET	    count,0
	  ADD	    ptr,ptr,:UNIT_SIZE
	  JMP	    3B
	  PREFIX    :