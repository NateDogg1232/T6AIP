'The 6502 Assembler and Interpreter Project Assembler (T6AIP-ASM)
'By: NateDogg1232

OPTION DEFINT:OPTION STRICT

'Required functions

'Set byte in INT
DEF SETBYTE(INP,BYTE,POS)
 BYTE=BYTE AND &HFF
 RETURN INP OR (BYTE<<(POS*8))
END
'Read byte in INT
DEF READBYTE(INP,POS)
 RETURN (INP AND (&HFF<<(POS*8)))>>(POS*8)
END

DEF PUSHBYTEARRAY ARR,BYTE
 IF ARR[0]>3 THEN
  ARR[0]=0
  PUSH ARR, BYTE AND &HFF
  RETURN
 ELSE
  ARR[LENSETBYTE(ARR[LEN(ARR)-1],BYTE,ARR[0])
  INC ARR[0],1
 ENDIF
END

DEF PREPAREBYTEARRAY ARR, SIZE
 aDel ARR
 'We use this as an index
 PUSH ARR,0
 'Then we add the size of the array
 FOR I=0 TO SIZE-1
  PUSH ARR,0
 NEXT I
END

COMMON DEF aDel A
 'Thanks, ShionAmasato
 IF LEN(A) THEN
  VAR V$="N"+"$"*((A[0]>0)>2),N,N$
  WHILE LEN(A)
   VAR(V$)=POP(A)
  WEND
 ENDIF
END

'DEF REPLACESLOW$(INP$,SEARCH$,REP$)
' VAR IDX
' 'We leave the source string alone
' VAR RET$=INP$
' VAR TMP1$,TMP2$,TMP3$
' WHILE TRUE
'  IDX=INSTR(RET$,SEARCH$)
'  IF IDX<0 THEN BREAK
'  TMP1$=LEFT$(RET$,IDX)
'  TMP2$=RIGHT$(RET$,LEN(RET$)-(IDX+LEN(SEARCH$)))
'  RET$=TMP1$+REP$+TMP2$
' WEND
' RETURN RET$
'END
DEF REPLACE$(INP$,SEARCH$,REP$)
 VAR IDX
 VAR RET$=INP$
 @LOOP
  IDX=INSTR(RET$,SEARCH$)
  IF IDX<0 THEN @SKIP
  RET$=LEFT$(RET$,IDX)+REP$+RIGHT$(RET$,LEN(RET$)-(IDX+LEN(SEARCH$)))
 GOTO @LOOP
 @SKIP
 RETURN RET$
END
DEF TOLOWER$(T$)
 VAR I
 FOR I=0 TO LEN(T$)-1
  IF ASC(T$[I])>64 AND ASC(T$[I])>91 THEN
   T$=SUBST$(T$,I,1,CHR$(ASC(T$[I])-32))
  ENDIF
 NEXT
 RETURN T$
END

DEF WARN STRING$
 COLOR #TOLIVE
 PRINT "[WARN]: ";
 COLOR #TWHITE
 PRINT STRING$
END
DEF INFO STRING$
 COLOR #TBLUE
 PRINT "[INFO]: ";
 COLOR #TWHITE
 PRINT STRING$
END
DEF ERR STRING$
 COLOR #TRED
 PRINT "[ERROR]: ";
 COLOR #TWHITE
 PRINT STRING$
END
'Split string into array using delimiter
'From Random's big dumb library
COMMON DEF STRINGSPLIT$(STRING$,DELIM$)
 DIM R$[0],THS=0,NXT
 WHILE #TRUE
  NXT=INSTR(THS,STRING$,DELIM$)
  IF NXT<0 THEN BREAK
  PUSH R$,MID$(STRING$,THS,NXT-THS)
  THS=NXT+1
 WEND
 PUSH R$,RIGHT$(STRING$,LEN(STRING$)-THS)
 RETURN R$
END

'Taken from Lowerdash
DEF TRIM$(S$)
  VAR T$ = " "
  WHILE LEFT$(S$,1) == T$
    S$ = RIGHT$(S$,LEN(S$)-1)
  WEND
  WHILE RIGHT$(S$,1) == T$
    S$ = LEFT$(S$,LEN(S$)-1)
  WEND
  RETURN S$
END

@INIT

ACLS
INFO "Loading"

'Index variables
VAR I,J,H

DIM PROG[0]

DIM HEADER[0]

VAR VER$="0.1"

'We use this as a do-fix table
DIM NEXTPASS$[0]
DIM NEXTPASS[0]

'Defined token
DIM DEFINETOK$[0]
'Defined value
DIM DEFINEVAL$[0]

VAR INFILE$=""
VAR OUTFILE$=""

DIM PROG$[0]

DIM TMPARR$[0]

VAR TMP$=""
VAR TMP=0
VAR TRASH$=""

VAR FILE$=""

VAR I$="",J$=""

VAR CURRLINE

PRINT "Welcome to T6AIP-ASM"

@CMD


WHILE TRUE
 PRINT "-";
 LINPUT I$
 I$=TRIM$(I$)
 J$=LEFT$(I$,1)
 IF J$=="I" THEN
  'Set the input file
  INFILE$=RIGHT$(I$,LEN(I$)-1)
  INFILE$=TRIM$(INFILE$)
  INFO "Input file set to "+INFILE$
  IF !CHKFILE("TXT:"+INFILE$) THEN
   WARN "File does not exist!"
  ENDIF
 ELSEIF J$=="O" THEN
  'Set the output file
  OUTFILE$=RIGHT$(I$,LEN(I$)-1)
  OUTFILE$=TRIM$(OUTFILE$)
  INFO "Output file set to "+OUTFILE$
 ELSEIF J$=="H" THEN
  ? "- `I (File)` - Sets input file
  ? "- `O (File)` - Sets output file
  ? "- `A` - Assemble
  ? "- `H` - Help
  ? "- `Q` - Quit
 ELSEIF J$=="A" THEN
  BREAK
 ELSEIF J$=="Q" THEN
  END
 ELSE
  ERR "Incorrect command"
 ENDIF
WEND

@PREPAREPROG

WARN "Pass 0: Preparing code"

TMP$=""
'Seperate the program into lines
PROG$=STRINGSPLIT$(FILE$, CHR$(10))

'Trim each line
FOR I=0 TO LEN(PROG$)-1
 PROG$[I]=TRIM$(PROG$[I])
NEXT I

WARN "Pass 0.5: Processing pre-pass directives"

FOR I=0 TO LEN(PROG$)-1
 'Skip blank lines and comments
 IF PROG$[I]=="" THEN CONTINUE
 IF LEFT$(PROG$[I],1)==";" THEN CONTINUE
 
 TMPARR$=STRINGSPLIT$(PROG$[I]," ")
 'Check for any pre-pass directives
 IF LEFT$(TMPARR$[0],1)=="." THEN
  'Now we know that the intention is a
  'directive
  IF TMPARR$[0]==".define" THEN
   PUSH DEFINETOK$, TMPARR$[1]
   PUSH DEFINEVAL$, TMPARR$[2]
  ENDIF
  
 ENDIF
NEXT I

CURRLINE=0

PREPAREBYTEARRAY(PROG)

@PASS1

WARN "Pass 1: Main pass"

'Check for a blank line
IF PROG$[CURRLINE]=="" THEN
 INC CURRLINE,1
 GOTO @PASS1
ENDIF
'Check for comments
IF LEFT$(PROG$[CURRLINE],1)==";" THEN
 INC CURRLINE,1
 GOTO @PASS1
ENDIF

TMPARR$=STRINGSPLIT$(PROG$,";") 'Remove all comments

'We replace any instance of any defined
'tokens with their values
FOR I=0 TO LEN(DEFINETOK$)-1
 TMPARR$[0]=REPLACE$(TMPARR$[0],DEFINETOK$[I],DEFINEVAL$[I])
NEXT

TMPARR$=STRINGSPLIT$(TRIM$(TMPARR$[0]), " ")

'We check the directives

'.db byte
IF TMPARR$[0]==".db" THEN
 


ENDIF

