.target "6502"
.setting "OutputfileType", "PRG"
.org $0801
thisopen .byte $0c, $08, $0a, $00, $9e, $20, $34, $30, $39, $36, $00, $00, $00
.org $1000

;LDA #$FE
;STA $B4
;LDA #$20
;STA $B5
;LDX #$00
;LDA ($B4,X)
;STA $2000
;INC $B4
;LDA ($b4,X)
;STA $2001
;INC $B4
;LDA ($b4,X)
;STA $2002
;INC $B4
;LDA ($b4,X)
;STA $2003
;BRK


CONFIG
    VeraRest =  $9F25
    VeraREG =   $9F20 
    VeraLO =    $9F20  ;Low Bit
    VeraMID =   $9f21 ;High Bit
    VeraHI =    $9f22
    VeraInc =   $9F22 ;Increment
    VeraDAT =   $9F23 ; Data out
    PLOT  =     $FFF0
    CHRIN =     $FFCF
    CHROUT =    $FFD2
    GETIN  =    $FFE4
    TESTBYTE =  $0002
    TESTBYTE2 = $00AC
    SCNKEY =    $FF9F
    PDirect =       $4002
    PSpeed  =       $4003
    CMPVAR  =       $4004 ; for tailsize stack change
    CMPVAR1 =       $4005
    TAILINT1 =      $4006 ; TailEnd Increase Interval 1
    TAILINT2 =      $4007 ; TailEnd Increase Interval 2
    GMOVERRSN =     $4008 ; Reason Game Ended... #$00 = Hit Wall, #$01 = Hit Self
    GMState   =     $4009 ; #$00 = TITLE, $#01 = normal play, #$02 and higher are end game states
    VARCHECKLO =    $f0 ; various checks of memory locations
    VARCHECKHI =    $f1 ; various checks of memory locations
    PTailSize =     $400A
    PTailMax  =     $400B
    PStartSpeed =   $400C
    SelDirect =     $4010
    CountInner =    $4011
    CountOuter =    $4012
    PREPX =         $4013
    PREPY =         $4014
    DummyVal1 =     $4015
    DummyVal2 =     $4016
    DummyVal3 =     $4017
    DummyVal4 =     $4018
    GetRND =        $4019 ; some value 0 - 255 (0 - FF)
    GetRND1 =       $401A
    StoreKey =      $401B
    StoreX1 =       $401C
    StoreY1 =       $401D
    PSpeedred =     $401E ;speed dely reduction value (number goes up, reducing delay)
    Pspeedmax =     $401F ;maz speed - PSpeedred can't go higher than this

    ;56 X 32
        DRPXMIN =       $401E; #$12
        DRPXMAX =       $401F; #$82
        DRPYMIN =       $4020; #$11
        DRPYMAX =       $4021; #$32
        DRPX =          $4022; #$00
        DRPY =          $4023; #$00
        DROPCOUNTER =   $4024
        DROPTARGET =    $4025
        DROPTARMIN =    $4026
        DROPDECTAR =    $4027
        DROPFLAG   =    $4028
        BGCOLOR =       $4029
    CHRROWCK =          $402A
    CHRCOLCK =          $402B
    CHRROWDR =          $402C
    CHRCOLDR =          $402D
    CHRVAL1  =          $402E
    CHRVAL2  =          $402F
    CHRCOLM  =          $4030
    CHRVALCLR   =       $4031    
    CHRVALCIRCLE =      $4032
    CHRVALTODRAW =      $4033
    CHRVALPICKUP =      $4034
    charstart =         $4035
    charend =           $4036
    MYNUM =             $4037
    CHRVAL3 =           $4038
    CHRVAL4 =           $4039
    CHARPAGE =          $403A
    PlayerX =           $4400
    PlayerY =           $4500
    PSpeedCounter =     $403B
    TEMPVAR10 =         $403C
    BGCOLORBASE =       $403D
    TITLESCREENSTART =  $2000

SETUP
    LDX #$00
    STX GMState ;SET GAMESTATE TO SHOW TITLE SCREEN SINCE 00 WILL TRIGGER THAT

    SETUP2;         ;JUMP HERE WHEN RESETTING SO TITLE ISN'T REDRAWN
        LDA #$93
        JSR CHROUT ; Clear the Screen
        LDX #$4A
        STX PlayerX ; Position the Player X at 4A
        LDX #$1F
        STX PlayerY ; Position the Player Y at 1F
                
        CONTSETUP
        LDX #$01
        STX PTailSize; short tail to start
        LDA #$63
        STA PTailMax
        
        LDX GMSTATE ;TESTING GAMESTATE, SHOULD BE 0 TO START SINCE SETUP HANDLES THAT
        CPX #$00      ;IF A ZERO, JUST KEEP GOING
        BEQ CGAMEISNOTRESET
        LDX #$01      ; OTHERWISE SET TO REGULAR PLAY (#$01), NOT TITLE (WHICH IS #$00)

        CGAMEISNOTRESET
        STX GMState ;set initial to title screen, afterward always just restart play
        LDX #$00
        STX VeraInc ; set auto increment to 0. Increasing caused issues back on emulator v 30 or so, so dropped it
        LDX PlayerX
        STX VeraLO
        LDX PlayerY
        STX VeraMID
        LDX #$02
        STX VeraDAT ;initial location
        ;LDA VARI 
        LDA #$02
        STA PDirect ;set direction 1,2, 3 or 4
        LDA #$03
        STA PSpeed ; set speed to 3 to start
        LDA #$00
        STA TAILINT1
        STA CountInner
        STA CountOuter
        STA GETRND
        STA GetRND1
        STA PSpeedCounter
        STA TEMPVAR10
        LDA #$32
        STA PStartSpeed
        LDA #$01
        STA BGCOLORBASE
        STA BGCOLOR
        JSR BLACKTHEBACK        
        LDA #$40
        STA Pspeedmax
        LDA #$FF        ;DELAY LENGTH (SEE SLOWDOWN SECTION) 
        STA PSpeedred
        
    ;pLAYFIELD XY
        LDA #$12
        STA DRPXMIN
        STA DRPX
        LDA #$11
        STA DRPYMIN
        sta DRPY
        LDA #$82
        STA DRPXMAX
        LDA #$31
        STA DRPYMAX 

    ;DROPVARIABLES
        LDA #$00
        STA DROPCOUNTER  ;COUNT MOVES, RESET EVERY DROP
        STA DROPFLAG     ;WHEN 1, DROP AN ITEM AT ADVCOUNTER LOCATION
        LDA #$05
        STA DROPTARMIN   ; MINIMUM MOVES BEFORE DROP HAPPENS, DON'T DROP SLOWER THAN THIS
        LDA #$14 
        STA DROPTARGET   ; AT THIS TARGET DROP A PICKUP, NUMBER OF MOVES BEFORE A DROP - IF SPACE NOT OCCUPIED
        LDA #$28 
        STA DROPDECTAR   ; EVERY TIME THIS HITS ZERO, REDUCE DROPTARGET UNTIL IT EQUALS DROPTARMIN
    ;OTHER VARIABLES
        LDA #$20
        STA CHRVALCLR ;   = $4031
        LDA #$51    
        STA CHRVALCIRCLE; = $4032
        STA CHRVALTODRAW

DrawTitle    
        LDX GMState
        CPX #$00
        BNE DrawBoard
        JSR TITLESCREEN


DrawBoard
    LDX #$03 ;WHICH ROW ON SCREEN TO START DRAWING
    STX CHRROWDR
    STX CHRVAL3
    LDX #$20 ;WHICH COLUMN TO START DRAWING ON (1 LESS THAN FINAL)
    STX CHRCOLM
    LDX #$00 ;LETTER TO SHOW FROM LABELENGTH TO USE, OFFSET FROM START OF LABEL
    STX charstart
    STX CHRVAL2
    LDX #$00 
    STX CHRVAL4 ; INDEX OF WORD
    
    DT2
    LDA LabelLength,X
    STA charstart 
    ;STY CHRCOLM
    JSR DRAWCHAR
    LDA CHRCOLM ;column WE'RE NOW SITTING AT
    ADC #$0F ; ADD 2 MORE COLUMNS
    STA CHRCOLM; NEW COLUMN TO START
    INC CHRVAL4 ;INCREASE LETTER
    LDA CHRVAL4
    CMP #$05 ;WE HIT THE LENGTH OF THIS WORD
    BEQ DrawLabels ;CONTINUE IF WE'RE AT LAST LETTER
    LDX CHRVAL3
    STX CHRROWDR
    TAX
    ;LDX CHRVAL2; PUT THE NEXT LETTER INDEX INTO X
    JMP DT2 ; OTHEWISE DRAW NEXT LETTER

    DrawLabels
        LDX #$0F  ; Snake Length and Snake Speed
        STX CMPVAR1
        STX VeraMID
        LDY #$12
        STY CMPVAR ; LO Value
        LDX #$00
    DRAWL1
        LDY CMPVAR ; Lo Value
        STY VeraLO
        LDY CMPVAR1 ;Mid Value
        STY VeraMID
        LDA LabelLength,X 
        STA VeraDAT
        INX
        INC CMPVAR
        INC CMPVAR
        LDA CMPVAR
        CMP #$4E
        BEQ DrawPlayField
        JMP DRAWL1

    DrawPlayField
        LDY #$12 ;start X
        DRAWTOPBOR
        STY VeraLO
        LDX #$10 ;Y
        STX VeraMID
        LDX #$40
        STX VeraDAT
        INY
        INY
        CPY #$82
        BEQ DRAWBOTBOR
        JMP DRAWTOPBOR 

        DRAWBOTBOR
        LDY #$12; Start X
        DBOTB
        STY VeraLO
        LDX #$31 ; Y
        STX VeraMID
        LDX #$40
        STX VeraDAT
        INY
        INY
        CPY #$82
        BEQ DRAWLBOR
        JMP DBOTB

        DRAWLBOR
        LDY #$11; Start X
        DLFTB
        LDX #$10
        STX VeraLO
        STY VeraMID
        LDX #$47
        STX VeraDAT
        INY
        CPY #$31
        BEQ DRAWRBOR
        JMP DLFTB

        DRAWRBOR
        LDY #$11; Start X
        DRAWRB
        LDX #$82
        STX VeraLO
        STY VeraMID
        LDX #$48
        STX VeraDAT
        INY
        CPY #$31
        BEQ DRAWCORNERS
        JMP DRAWRB

    DRAWCORNERS
        LDX #$10 ; UL
        STX VeraLO
        STX VeraMID
        LDX #$55
        STX VeraDAT

        LDX #$82 ; UR
        STX VeraLO
        LDX #$10
        STX VeraMID
        LDX #$49
        STX VeraDAT

        LDX #$10 ; LL
        STX VeraLO
        LDX #$31
        STX VeraMID
        LDX #$4A ;curve LL
        STX VeraDAT

        LDX #$82 ; LR
        STX VeraLO
        LDX #$31
        STX VeraMID
        LDX #$4B ;curve LR
        STX VeraDAT

GO  
    LDA PTailSize
    CMP #$04
    BCC CHECKKEY
    STA PSpeed

    CHECKKEY
    LDA #$00
    SEI ;override interrupt so keys can be read with my routine
    JSR SCNKEY      ;SCAN KEYBOARD
    JSR GETIN       ;GET CHARACTER
    STA StoreKey
   ; CMP #0          ;IS IT NULL?
   ; JMP GetSetDir; BNE GetSetDir      ;No, evaluate what was pressed
   ; JMP go           ;YES... SCAN AGAIN
    LDA GMState
    CMP #$01
    BEQ PrepSlow
    CMP #$00
    BEQ DTITLE
    JMP THEEND
    DTITLE
    LDA StoreKey
    CMP #$20
    BEQ STARTGAME
    JMP DrawTitle
    STARTGAME
    LDA #$01
    STA GMSTATE
    JMP SETUP2

PrepSlow ;most of this is dummy activity to slow the snake down
    LDY #$FF ;prep slowdown
    STY DummyVal1
    STY DummyVal2
  
    SlowStep1
        JSR ADVDROP
        DEC DummyVal1
        LDX #$FE
        LDY #$FF
        Slow1 
        ASL DummyVal3,X

        DEY
        TYA
        RSL
        SBC PSpeed
        CMP #$30    ;For slowdown, the higher this number, the faster the snake but take into account the
                    ;timer (y) starts at #$FF and the snake length is subtracted from Y, so if you aren't 
                    ;careful with your math, you could subtract past this value and potentially never hit it
        BNE Slow1

        LDA DummyVal1
        CMP #$F0 
        BNE SlowStep2
        JMP SlowStep1

    SlowStep2
        DEC DummyVal2
        DEC DummyVal1
        LDX #$FE
        ASL DummyVal3,X
         
        LDA DummyVal2
        SBC PTAILSIZE
        CMP #$70
        BEQ SS2Next
        JMP SlowStep1
        ;INC PSpeedCounter  ;COUNT BEFORE INCREASING SPEED
        ;LDA #$00
        ;STA VeraLO
        ;STA VeraMID
        ;LDA PSpeed
        ;STA VERADAT
        ;LDA PSpeedCounter
        ;CMP #$FF           ;EVERY 255 CYCLES WITH THIS SETTING
        ;BNE SS2Next        ;IF NOT AT 255, JUMP TO NEXT TIME WASTER SECTION
        ;DEC PSpeedred      ;OTHERWISE REDUCE PSPEEDRED (STARTS AT FF)
        ;INC PSpeed
        ;LDA Pspeedmax      ;LOAD THE MAX VALUE WE WANT FOR SPEED UP
        ;CMP PSpeedred      ;COMPARE TO CURRENT PSPEEDRED
        ;BNE SS2Next        ;IF NOT MAX, JUST KEEP GOING
        ;INC PSPEEDRED       ;DON'T GO FASTER THAN MAX
        ;DEC PSpeed

        SS2Next
       ; INC DummyVal2
       ; LDA PStartSpeed
        ;SBC PSpeed
        ;SBC PSpeed
        
        ;ROR ; AVOID GETTING crazy fast by dividing increase by 2
        ;STA CMPVAR
        ;LDA DummyVal2
        ;CMP CMPVAR; #$60
        ;BEQ DEVRANDOM
        ;JMP SlowStep1

    ;DEVRANDOM
    ;JMP GetSetDir

GetSetDir
    LDA StoreKey
    STA SelDirect ;W = #$57/#$91, S = #$54/#$11; A = #$41/$9D; D = #$44/#$1D
    CMP #$57
    BEQ DIRUP
    CMP #$91
    BEQ DIRUP
    CMP #$53
    BEQ DIRDN
    CMP #$11
    BEQ DIRDN
    CMP #$41
    BEQ DIRLT
    CMP #$9D
    BEQ DIRLT
    CMP #$44
    BEQ DIRRT
    CMP #$1D
    BEQ DIRRT
    ;LDA StoreKey ;NOTHING to Handle... grab last direction 
    ;STA StoreKey ;store it again for safe measure
    JMP INCCOUNTER ;nothing matches valid keys, so move on
    
    DIRUP LDA #$01
    JMP SetDIR
    DIRDN LDA #$03
    JMP SetDIR
    DIRLT LDA #$04
    JMP SetDIR
    DIRRT LDA #$02
    SetDIR STA PDirect ; get new direction and place in PDirect
    
INCCOUNTER
    LDY CountInner
    LDX #$08
    STX VeraLO
    LDX #$06
    STX VeraMID
    LDY CountOuter
    ;STY VeraDAT
    INC CountOuter
    LDA CountOuter
    CMP #$04
    BEQ COUNTER2
    JMP ADDTOSNAKE

    COUNTER2
    JMP CONTINCNT

    CONTINCNT
    INC CountInner
    CMP #$04
    BNE ADDTOSNAKE

ADDTOSNAKE

   CKWALLHIT
    LDA PDirect ;GET SNAKE DIRECTION
    CMP #$01    ;IF IT'S A 1
    BEQ CHKUP1   ;CHECK ABOVE (ROW - 1)
    CMP #$02    ;IF IT'S A 2
    BEQ CHKRT1   ;CHECK TO THE RIGHT (COLUMN + 2)
    CMP #$03    ;IF IT'S A 3
    BEQ CHKDN1   ;CHECK BELOW (ROW + 1)
    CMP #$04    ;CHECK TO THE LEFT
    BEQ CHKLT1   ;CHECK TO THE LEFT (COLUMN - 2)
    JMP PUSHSTACKPREP ;eventually check OTHER KEYS

    CHKUP1
    jmp CHKUP
    CHKRT1
    jmp CHKRT
    CHKDN1
    jmp CHKDN
    CHKLT1
    jmp CHKLT


    CHKUP
    LDX PlayerX ;GET THE PLAYER'S X VALUE
    STX VeraLO  ;STORE IT IN VERA LO BYTE
    LDX PlayerY ;GET THE PLAYER'S CURRENT Y VALUE
    DEX         ;SINCE WE'RE CHECKING THE ROW ABOVE, DECREMENT X TO LOOK AT ROW ABOVE
    STX VeraMID ;STORE X IN THE VERA MIDDLE BYTE (REMEMBER WE'RE IN BANK 0 FOR SIMPLICITY)
    LDA VeraDAT ;READ THE INFORMATION AT THIS LOCATION NOW THAT WE HAVE THE POINTER SET TO PLAYER X AND PLAYER Y - 1 (LOGICALLY)
    CMP #$40    ;COMPARE THIS VALUE TO THE VALUE USED FOR UPPER WALL
    BEQ CHKUPENDHIT   ;GO TO ROUTINE THAT HANDLES A HIT AGAINST THE WALL
    CMP CHRVALCIRCLE  ;NOW COMPARE THE LOCATION TO THE SNAKE CHARACTER
    BEQ CHKUPENDHITSL   ;IF HIT, GO TO ROUTINE TO GIVE ENDGAME BASED ON HITTING ONESELF 
    CMP CHRVALPICKUP  ;IF A PICKUP 
    BEQ PICKUP1       ;GO TO ROUTINE TO HANDLE PICKUPS
    CMP #$A0            ;IF HIT BLOCK
    BEQ CHKUPENTHITBLK
    JMP PUSHSTACKPREP ;SINCE I ONLY COME TO THIS ROUTINE IF USER PRESSED UP, I DON'T HAVE TO CHECK OTHER DIRECTIONS, SO GO TO NEXT ROUTINE
    CHKUPENDHIT
    LDX #$01
    STX GMOVERRSN
    JMP ENDHITsomething    ;USING JMP'S BECAUSE, IF EXPECTED BEQ'S OR BNE'S, THE BRANCHES ARE TOO FAR AWAY FOR MY CODE
    CHKUPENDHITSL
    LDX #$02
    STX GMOVERRSN
    JMP ENDHITsomething    ;USING JMP'S BECAUSE, IF EXPECTED BEQ'S OR BNE'S, THE BRANCHES ARE TOO FAR AWAY FOR MY CODE
    CHKUPENTHITBLK
    LDX #$03
    STX GMOVERRSN
    JMP ENDHITsomething    ;USING JMP'S BECAUSE, IF EXPECTED BEQ'S OR BNE'S, THE BRANCHES ARE TOO FAR AWAY FOR MY CODE
    
    PICKUP1
    JMP PICKUP        ;SAME THOUGHT HERE, GAME END ROUTINE'S ARE AT THIS AND THE ENDHITWALL JMP'S

    CHKRT
    LDX PlayerX
    INX
    INX
    STX VeraLO
    LDX PlayerY
    STX VeraMID
    LDA VeraDAT
    CMP #$48
    BEQ CHKRTENDHIT 
    CMP CHRVALCIRCLE ;SNAKE CHARACTER
    BEQ CHKRTENDHITSL
    CMP #$57 ;FOUND PICKUP
    BEQ PICKUP2
    CMP #$A0            ;IF HIT BLOCK
    BEQ CHKRTENDHITBLK
    JMP PUSHSTACKPREP
    CHKRTENDHIT
    LDX #$01
    STX GMOVERRSN
    JMP ENDHITsomething
    CHKRTENDHITSL
    LDX #$02
    STX GMOVERRSN
    JMP ENDHITsomething
    CHKRTENDHITBLK
    LDX #$03
    STX GMOVERRSN
    JMP ENDHITsomething    ;USING JMP'S BECAUSE, IF EXPECTED BEQ'S OR BNE'S, THE BRANCHES ARE TOO FAR AWAY FOR MY CODE
    
    PICKUP2
    JMP PICKUP

    CHKDN
    LDX PlayerX
    STX VeraLO
    LDX PlayerY
    INX
    STX VeraMID
    LDA VeraDAT
    CMP #$40
    BEQ CHKDNENDHIT 
    CMP CHRVALCIRCLE ;SNAKE CHARACTER
    BEQ CHKDNENDHITSL
    CMP #$57 ;FOUND PICKUP
    BEQ PICKUP3
    CMP #$A0 ;HIT BLOCK
    BEQ CHKDNENDHITBLK
    
    JMP PUSHSTACKPREP
    CHKDNENDHIT
    LDX #$01
    STX GMOVERRSN
    JMP ENDHITsomething
    CHKDNENDHITSL
    LDX #$02
    STX GMOVERRSN
    JMP ENDHITsomething
    
    CHKDNENDHITBLK
    LDX #$03
    STX GMOVERRSN
    JMP ENDHITsomething
    PICKUP3
    JMP PICKUP

    CHKLT
    LDX PlayerX
    DEX
    DEX
    STX VeraLO
    LDX PlayerY
    STX VeraMID
    LDA VeraDAT
    CMP #$47
    BEQ CHLTENDHIT 
    CMP CHRVALCIRCLE ;SNAKE CHARACTER
    BEQ CHLTENDHITSL
    CMP #$57 ;FOUND PICKUP
    BEQ PICKUP4
    CMP #$A0 ; HIT BLOCK
    BEQ CHKLTENDHITBLK
    JMP PUSHSTACKPREP
    CHLTENDHIT
    LDX #$01
    STX GMOVERRSN
    JMP ENDHITsomething
    CHLTENDHITSL
    LDX #$02
    STX GMOVERRSN
    JMP ENDHITsomething
    CHKLTENDHITBLK
    LDX #$03
    STX GMOVERRSN
    JMP ENDHITsomething
    
    PICKUP4
    JMP PICKUP

    ENDHITsomething 
    LDX #$02
    STX GMState

    JSR BLACKTHEBACK
    JSR BLACKTHEFRONT

    jsr Drawgameover
    jsr DRAWReason

    drawrestartoptions
    ;LabelEndOptions
    LDA #$20
    STA DummyVal1
    LDX #$2F  ; draw endgame options Space or Q
    STX CMPVAR1
    STX VeraMID
    LDY #$26
    STY CMPVAR ; LO Value
    LDX #$00
    DRAWOpt1
    INC DummyVal1
    LDY CMPVAR ; Lo Value
    STY VeraLO
    LDY CMPVAR1 ;Mid Value
    STY VeraMID
    LDA LabelEndOptions,X 
    STA VeraDAT
    INC CMPVAR
    INC CMPVAR1
    LDA CMPVAR1
    STA VERAMID
    LDA CMPVAR
    STA VeraLO
    LDA LabelEndOptions,X
    TXA
    ADC DummyVal1    
    STA VERADAT
    DEC CMPVAR
    DEC CMPVAR1
    INX
    INC CMPVAR
    INC CMPVAR
    LDA CMPVAR
    CMP #$68
    BEQ EndEndGameDraw
    JMP DRAWOpt1

    EndEndGameDraw
    JMP PUSHSTACKPREP

ENDSNAKEHIT
    LDX #$02
    STX GMState
    LDX #$03
    STX GMOVERRSN
    ;STX VeraLO
    ;LDX #$05
    ;STX 
    ;LDA PDirect
    ;STA VeraDAT
    JMP PUSHSTACKPREP

PICKUP
    INC PTailSize
    LDA PTailMax
    BCS PICKUPLIMITSIZE;BEQ PICKUPLIMITSIZE
    JMP PUSHSTACKPREP
    PICKUPLIMITSIZE
    DEC PTAILSIZE ; Immediately remove added segment if we've hit max

            PUSHSTACKPREP
            ;prepstack
            LDX PTailSize
            LDY PTailSize
            
            PUSHSTACK
            LDA PlayerX,X
            INX
            STA PlayerX,X
            DEX
            LDA PlayerY,X
            INX
            STA PlayerY,X 
            DEX

            ;LDA #$02 ;DrawTailSize
            ;STA VeraMID
            ;LDA #$64
            ;STA VeraLO
            ;TXA
            ;LDA PTailSize
            ;STA VeraDAT ;end DrawTailSize

            ;shift down
            TYA
            CMP #$00
            BEQ PSTART
            DEY
            DEX 
            JMP PUSHSTACK

            PSTART
            ;Only increase every so many cycles
            INC TAILINT1
            LDA TAILINT1
            CMP #$10
            BNE DROPTHINGS1
            LDA #$00
            STA TAILINT1

            LIMITLENGTH
            LDA PTailSize ;get current tail length
            ;STA BGCOLOR
            JSR COLORTHEDROPS
            LDA PTAILSIZE
            CMP #$63      ;compare it to 99
            BCC AddSeg ;BNE AddSeg    ; if not 99, add a segment
            JMP DROPTHINGS1  ; move on to next step
            
            AddSeg
            INC PTailSize     
            STA CMPVAR
            LDX PTailMax
            ;LDA PTailSize
            AddSegCkSize
            CPX CMPVAR
            BEQ ADDSegSetMax
            INX
            CPX #$FF
            BEQ DROPTHINGS1
            JMP AddSegCkSize

            BNE DROPTHINGS1
            
            ADDSegSetMax
            LDA PTailMax
            STA PTailSize ;KEEP TAIL AT 99 OR UNDER
            

DROPTHINGS1
    INC DROPCOUNTER  ;INCREASE DROP COUNTER BY 1
    DEC DROPDECTAR   ;DEC TIMER TO THE ACTUAL DROP
    LDA DROPCOUNTER  ;LOAD THE COUNTER TO CHECK
    CMP DROPTARGET   ;SEE IF WE'VE HIT THE DROPTARGET (STARTING AT #$14)
    BNE DROPCHECKMIN ;IF HAVEN'T HIS YET, GO SEE IF WE NEED TO DEAL WITH THE TARGET #'S
    LDA #$01         ;OTHERWISE SET THE FLAG TO DROP SOMETHING (IF SPOT EMPTY)
    STA DROPFLAG     ;FLAG OF #$01 NOW SET IN DROPFLAG, WHETHER A DROP HAPPENS OR NOT, THIS SHOULD BE RESET TO 00
    LDA #$00
    STA DROPCOUNTER

    DROPCHECKMIN     ;SEE IF WE WANT TO SPEED UP DROPS
    LDA DROPDECTAR   ;HAS OUR SPECIAL SPEED UP TIMER
    CMP #$00         ;HIT ZERO YET?
    BNE DROPITEM     ;IF NOT, CONTINUE GAME
    DEC DROPTARGET   ;IF SO, LOWER THE TARGET SPEED FOR DROPS
    LDA DROPTARGET   ;NOW LET'S CHECK IF WE'VE HIT THE MINUMUM
    CMP DROPTARMIN   ;SO COMPARE DROPTARGET TO THAT MINUMUM
    BNE DROPITEM     ;IF NOT, CONTNUE GAME
    INC DROPTARMIN   ;IF SO, JUST INCREASE AGAIN
    INC DROPDECTAR   ;AND INCREMENT DROPDECTAR AGAIN SO IT DOESN'T CYCLE BACK DOWN FROM $#FF

    DROPITEM
    LDA DROPFLAG
    CMP #$01
    BEQ DROPIT 
    JMP KEYCHECK
    DROPIT
    LDA #$00 
    STA DROPFLAG
    LDA DRPX
    STA VeraLO
    LDA DRPY
    STA VeraMID
    LDA VeraMID
    CMP #$20
    LDA DRPX
    STA VeraLO
    LDA DRPY
    STA VeraMID
    LDA #$57 ;empty circle
    STA VeraDAT
    JMP KEYCHECK ;MAKE SURE TO GO TO KEYCHECK 

KEYCHECK

    LDA #$01
    CMP PDirect
    BEQ CHECKW ;up
    LDA #$02
    CMP PDirect
    BEQ CHECKD ;dn
    LDA #$03
    CMP PDirect
    BEQ CHECKS ;right 
    LDA #$04
    CMP PDirect
    BEQ CHECKA ;left
    JMP go

    CHECKW 
    LDX PlayerY
    CPX #$11
    BEQ DRAWROUTINE
    DEC PlayerY
    JMP DRAWROUTINE    

    CHECKS 
    LDX PlayerY
    CPX #$30
    BEQ DRAWROUTINE
    INC PlayerY
    JMP DRAWROUTINE

    CHECKA 
    LDX PlayerX
    CPX #$12  ;stay in bounds - left boundry #$10
    BEQ DRAWROUTINE ;if not 12, go to draw routine
    DEC PlayerX
    DEC PlayerX
    JMP DRAWROUTINE

    CHECKD
    LDX PlayerX
    CPX #$80  ;stay in bounds - right boundry #$80
    BEQ DRAWROUTINE ;if not 80, go to draw routine
    INC PlayerX
    INC PlayerX
    JMP DRAWROUTINE

DRAWROUTINE 
            ;LDA PTAILSIZE
            ;STA $7000
            LDA GMState ;PREVENT ADDITIONAL DRAWS IF IN GAMESTATE 1 OR 2 (GAME OVER)
            CMP #$01
            BEQ DRAWLENGTH
            JMP THEEND

        DRAWLENGTH
            LDX #$30
            STX VeraLO
            LDX #$0F
            STX VeraMID
            LDA PTailSize
            ASL
            TAX 
            LDA LabelNumbers, X 
            STA VeraDAT
            LDX #$32
            STX VeraLO
            LDX #$0F
            STX VeraMID
            LDA PTailSize
            ASL
            TAX 
            INX 
            LDA LabelNumbers, X 
            STA VeraDAT
            JMP DRAWSPEED

        DRAWSPEED
            LDX #$4E
            STX VeraLO
            LDX #$0F
            STX VeraMID
            LDA PSpeed
            ASL
            TAX 
            LDA LabelNumbers, X 
            STA VeraDAT
            LDX #$50
            STX VeraLO
            LDX #$0F
            STX VeraMID
            LDA PSpeed
            ASL
            TAX 
            INX 
            LDA LabelNumbers, X 
            STA VeraDAT
            JMP THESNAKE

        THESNAKE
            LDX #$00 
            CSDraw1
            LDA PlayerX,X
            STA VeraLO
            LDA PlayerY,X 
            STA VeraMID
            LDA CHRVALCIRCLE ;snake body circle
            STA VeraDAT
            LDA PlayerX,X
            TAY ;change bg behind snake
            INY
            STY VeraLO
            LDY #$01
            STY VeraDAT
            TXA
            CMP PTailSize
            BEQ EraseTail
            INX 
            JMP CSDraw1

        EraseTail
            LDA PlayerX,X
            STA VeraLO
            LDA PlayerY,X 
            STA VeraMID
            LDA #$20
            STA VERADAT
            ;Erase bground color
            LDA PlayerX,X
            TAY 
            INY
            TYA
            STA VeraLO
            LDA PlayerY,X
            STA VeraMID
            lda #$01
            STA VeraDAT
            LDA #$00
            STA PlayerX,X 
            STA PlayerY,X
            JMP WaitSpace

        Handlean01
            LDY #$01
            LDA PlayerX,Y 
            STA VeraLO
            LDA PlayerY,Y 
            STA VeraMID
            LDA #$20
            STA VeraDAT
            RTS

WaitSpace  LDA $0002
           CMP #$EF
           BEQ STARTAGAIN; STARTAGAIN
           
           LDA GMState
           CMP #$01
           BEQ STARTAGAIN
           CMP #$01
           BEQ THEEND

           LDA $0002
           AND #$20
           CMP #$20
           .byte $ff
           BEQ RESET
    
    STARTAGAIN 
        JMP GO

    RESET 
        LDA #$01
        STA GMState
        JMP SETUP2


THEEND 
    LDA #$02 ;checking game state
    CMP GMState
    BEQ FINAL
    LDA #$03
    CMP GMState
    BEQ FINAL

FINAL
    LDA StoreKey
    CMP #$20
    BEQ NOWRESTART
    CMP #$51
    BEQ FINALEND
    RECHECK
    JMP CHECKKEY
    NOWRESTART
    JMP SETUP
    FINALEND
    BRK

;ABCDEFGHIJ  KLMNOPQRST UVWXYZ
LabelLength .byte 19, 14, 01, 11, 05, 32, 12, 05, 14, 07, 20, 8, 58, 32, 32, 32, 32, 32,  19, 14, 01, 11, 05, 32, 19, 16, 05, 05, 04, 58
LabelNumbers .byte 48,48,48,49,48,50,48,51,48,52,48,53,48,54,48,55,48,56,48,57,49,48,49,49,49,50,49,51,49,52,49,53,49,54,49,55,49,56,49,57,50,48,50,49,50,50,50,51,50,52,50,53,50,53,50,54,50,55,50,56,51,48,51,49,51,50,51,51,51,52,51,53,51,54,51,55,51,56,51,57,52,48,52,49,52,50,52,51,52,52,52,53,52,54,52,55,52,56,52,57,53,48,53,49,53,50,53,51,53,52,53,53,53,54,53,55,53,56,53,57,54,48,54,49,54,50,54,51,54,52,54,53,54,54,54,55,54,56,54,57,55,48,55,49,55,50,55,51,55,52,55,53,55,54,55,55,55,56,55,57,56,48,56,49,56,50,56,51,56,52,56,53,56,54,56,55,56,56,56,57,57,48,57,49,57,50,57,51,57,52,57,53,57,54,57,55,57,56,57,57
LabelGameOver .byte 07, 01, 13, 05, 32, 15, 22, 05, 18
LabelHitWall  .byte 32,08,09,20,32,23,01,12,12
LabelHitSelf  .byte 32,08,09,20,32,19,05,12,06
LabelEndOptions .byte 16,18,5,19,19,32,19,16,1,3,5,32,20,15,32,18,5,19,20,1,18,20,44,17,32,20,15,32,17,21,9,20,46
LabelHitblock .byte 08,09,20,32,02,12,15,03,11

ADVDROP ;THIS SUBROUTINE HANDLES THE POSITION OF A "PEN" HOVERING OVER THE PLAYFIELD. WHEN TRIGGERED THE PEN
        ;DRAWS A PICKUP. THIS IS SUBSTITUTE TO A "PICK A RANDOM X AND Y LOCATION" 
    INC DRPX
    INC DRPX

    LDA DRPX
    CMP DRPXMAX
    BEQ ADVGETOUTX
    JMP GETOUTADVDROP

    ADVGETOUTX
    LDA DRPXMIN
    STA DRPX

    INC DRPY
    LDA DRPY

    CMP DRPYMAX
    BNE GETOUTADVDROP
    LDA DRPYMIN
    STA DRPY

    GETOUTADVDROP
    RTS

BLACKTHEBACK ;THIS SUBROUTINE SET THE BACKGROUND TO BLACK BY STARTING AT THE 1ST BACKGROUND COLOR SPOT (VERA BANK 0 
            ; MEMORY LOCATION 1) AND INCREMENTING THROUGH THE VISIBLE 80 COLUMNS - EVERY OTHER ONE - LOADING IN THE
            ;BGCOLORBASE VALUE (BLACK)
        LDX #$01 ;1ST POSITION
        LDY #$00 ;1ST BANK
        BTB2
        STX VeraLO
        STY VeraMID
        LDA BGCOLORBASE
        STA VERADAT
        INX
        INX
        CPX #$A1    ;ONE PAST THE LAST VISIBLE COLUMN
        BEQ INCOURY ;IF WE HIT A1, WE INCREASE Y AND RESET X TO 1
        JMP BTB2
        INCOURY
        LDA #$01    ;RESET TO THE 1ST COLUMN 
        TAX         ;BY LOADING VALUE IN A AND RESETTING X TO HOLD THAT NUMBER
        INY         ;GO DOWN A ROW
        CPY #$3C    ;ONE PAST THE BOTTOM ROW
        BEQ BTBEND  ;LEAVE THE SUBROUTINE IF A MATCH
        JMP BTB2    ;OTHERWISE, GO BACK TO DRAWING
        BTBEND
        RTS

BLACKTHEFRONT
        LDX #$00
        LDY #$00
        BTF2
        STX VeraLO
        STY VeraMID
        LDA #$20 
        STA VERADAT
        INX
        INX
        CPX #$A0
        BEQ INCOURFY
        JMP BTF2
        INCOURFY
        INY
        CPY #$3C
        BEQ BTFEND; CONTSETUP
        JMP BTF2
        BTFEND
        RTS

COLORTHEDROPS
        LDX #$00
        LDY #$00
    CTD2
        STX VeraLO
        STY VeraMID
        LDA #$00
        ;STA VeraDAT
        LDA VeraDAT
        CMP #$57 
        BEQ COLORDROP
        INX
        INX
        JMP CTDCONTINUE
    COLORDROP
        INC BGCOLOR
        LDA BGCOLOR
        CMP #$0F
        BNE CDROPCONT
        LDA #$01
        STA BGCOLOR
        STX CMPVAR1 ;HOLD ON TO X
        STX VERALO
        LDX #$A0    ;SOLIDIFY THE BLOCK
        STX VERADAT
        LDX CMPVAR1 ;RETURN STORED X VAL TO X

        CDROPCONT
        INX
        STX VeraLO
        LDA BGCOLOR ;PTailSize
        STA VeraDAT
        INX
        ;brk
    CTDCONTINUE
        CPX #$A0
        BEQ CTDYINC
        JMP CTD2
    CTDYINC
        INY
        CPY #$3C
        BEQ CTDEND 
        JMP CTD2
    CTDEND
        RTS


DRAWCHAR
;letter routine, all needed for a jsr
    ;LDX #$03 ;the letter to draw, C
    ;STX charstart ; i'll need to multiply this by 8
    ;LDX #$0f ; choose which row to draw on
    ;STX CHRROWDR
    ;LDX #$10 ; choose a column to start drawing at
    ;STX CHRCOLM
;The routine I JSR to
LDA #$F0
STA CHARPAGE ;MIDDLE BYTE OF CHARACTERS
LDA charstart ; get the character set up by the JSR
STA CMPVAR
;MAKE ADJUSTMENTS BASED ON CHARACTER CHOSEN
CMP #$DF
BCS CHARTIMES8
CMP #$BF
BCS CHARTIMES7
CMP #$9F
BCS CHARTIMES6
CMP #$7F
BCS CHARTIMES5
CMP #$5F
BCS CHARTIMES4
CMP #$3F
BCS CHARTIMES3
CMP #$20
BCS CHARTIMES2
LDA CMPVAR
JMP  CHARSETUP
CHARTIMES8
LDX #$F7
STX CHARPAGE 
LDA CMPVAR
SBC #$F0
STA CMPVAR
JMP CHARSETUP
CHARTIMES7
LDX #$F6
STX CHARPAGE
LDA CMPVAR
SBC #$C0
STA CMPVAR
JMP CHARSETUP
CHARTIMES6
LDX #$F5
STX CHARPAGE
LDA CMPVAR
SBC #$A0
STA CMPVAR
JMP CHARSETUP
CHARTIMES5
LDX #$F4
STX CHARPAGE
LDA CMPVAR
SBC #$80
STA CMPVAR
JMP CHARSETUP
CHARTIMES4
LDX #$F3
STX CHARPAGE
LDA CMPVAR
SBC #$60
STA CMPVAR
JMP CHARSETUP
CHARTIMES3
LDX #$F2
STX CHARPAGE
LDA CMPVAR
SBC #$40
STA CMPVAR
JMP CHARSETUP
CHARTIMES2
LDX #$F1
STX CHARPAGE
LDA CMPVAR
SBC #$20
STA CMPVAR


CHARSETUP

LDA CMPVAR
STA charstart
;STA CMPVAR
ASL
ASL
ASL ;MULTIPLY BY 8

CSTART
STA charstart  ; repurpose this to turn starting character index to actual memory location of chosen letter
ADC #$07       ;add 7 to the character chosen so I get all 8 bytes
STA charend    ;store this as the last byte to look at
LDX charstart  ;now set charstart value to chrrowck 
;STX MYNUM     ;here
STX CHRROWCK   ;ROW TO CHECK IN MEMORY

AGAIN
LDX CHRROWCK ;load row to check
STX VeraLO   ;SET LO POINTER To byte I want
LDX CHARPAGE     ;MIDDLE BYTE OF CHAR ROM ADDRESS
STX VeraMID  ;STORE IT AT POINTER ADDRESS
LDX #$01     ;CHAR ROM BANK is 1
STX VeraHI   ;SET TO THIS BANK
LDX VeraDAT  ;NOW GET THE DATA FROM 01F000 (+ x DUE TO Chrrowck)
STX CHRVAL1  ;STORE IT IN CHRVAL1 FOR MANUPULATION

LDX #$00 ;RESET TO BANK0
STX VeraHI

SHOWME7
LDA CHRVALCIRCLE ;set default character
STA CHRVALTODRAW ;to draw
LDA CHRVAL1      ;MOVE STORED VALUE (Byte of char being looked at) TO ACCUMULATOR
AND #$80         ;CHECK 128
CMP #$80
BEQ DRAW7        ;N0 128
SM7CLR
LDA CHRVALCLR    ;switch to clear char
STA CHRVALTODRAW
DRAW7
LDY CHRCOLM
STY VeraLO
LDY CHRROWDR
STY VeraMID
LDY CHRVALTODRAW
STY VeraDAT

SHOWME6
LDA CHRVALCIRCLE
STA CHRVALTODRAW
INC CHRCOLM ;CHANGE COLUMN FOR NEXT DRAW
INC CHRCOLM
LDA CHRVAL1
CMP #$20
BEQ SM6CLR
AND #$40 ;CHECK 64
CMP #$40
BEQ DRAW6
SM6CLR
LDA CHRVALCLR
STA CHRVALTODRAW
DRAW6
LDY CHRCOLM
STY VeraLO
LDY CHRROWDR
STY VeraMID
LDA CHRVALTODRAW
STA VeraDAT

SHOWME5
LDA CHRVALCIRCLE
STA CHRVALTODRAW
INC CHRCOLM ;CHANGE COLUMN FOR NEXT DRAW
INC CHRCOLM
LDA CHRVAL1 ;MOVE STORED VALUE TO ACCUMULATOR
CMP #$20
BEQ SM5CLR
AND #$20 ;CHECK 32
CMP #$20
BEQ DRAW5
SM5CLR
LDA CHRVALCLR
STA CHRVALTODRAW
DRAW5
LDY CHRCOLM
STY VeraLO
LDY CHRROWDR
STY VeraMID
LDY CHRVALTODRAW
STY VeraDAT

SHOWME4
LDA CHRVALCIRCLE
STA CHRVALTODRAW
INC CHRCOLM ;CHANGE COLUMN FOR NEXT DRAW
INC CHRCOLM
LDA CHRVAL1;MOVE STORED VALUE TO ACCUMULATOR
AND #$10 ;CHECK 16
CMP #$10
BEQ DRAW4

SM4CLR
LDA CHRVALCLR
STA CHRVALTODRAW
DRAW4
LDY CHRCOLM
STY VeraLO
LDY CHRROWDR
STY VeraMID
LDA CHRVALTODRAW
STA VeraDAT

SHOWME3
LDA CHRVALCIRCLE
STA CHRVALTODRAW
INC CHRCOLM ;CHANGE COLUMN FOR NEXT DRAW
INC CHRCOLM
LDA CHRVAL1;MOVE STORED VALUE TO ACCUMULATOR
AND #$08 ;CHECK 8
CMP #$08
BEQ DRAW3

SM3CLR
LDA CHRVALCLR
STA CHRVALTODRAW
DRAW3
LDY CHRCOLM
STY VeraLO
LDY CHRROWDR
STY VeraMID
LDA CHRVALTODRAW
STA VeraDAT

SHOWME2
LDA CHRVALCIRCLE
STA CHRVALTODRAW
INC CHRCOLM ;CHANGE COLUMN FOR NEXT DRAW
INC CHRCOLM
LDA CHRVAL1;MOVE STORED VALUE TO ACCUMULATOR
AND #$04 ;CHECK 4
CMP #$04
BEQ DRAW2

SM2CLR
LDA CHRVALCLR
STA CHRVALTODRAW
DRAW2
LDY CHRCOLM
STY VeraLO
LDY CHRROWDR
STY VeraMID
LDA CHRVALTODRAW
STA VeraDAT

SHOWME1
LDA CHRVALCIRCLE
STA CHRVALTODRAW
INC CHRCOLM ;CHANGE COLUMN FOR NEXT DRAW
INC CHRCOLM
LDA CHRVAL1;MOVE STORED VALUE TO ACCUMULATOR
AND #$02 ;CHECK 2
CMP #$02
BEQ DRAW1

SM1CLR
LDA CHRVALCLR
STA CHRVALTODRAW
DRAW1
LDY CHRCOLM
STY VeraLO
LDY CHRROWDR
STY VeraMID
LDA CHRVALTODRAW
STA VeraDAT

SHOWME0
    LDA CHRVALCIRCLE
    STA CHRVALTODRAW
    INC CHRCOLM ;CHANGE COLUMN FOR NEXT DRAW
    INC CHRCOLM
    LDA CHRVAL1;MOVE STORED VALUE TO ACCUMULATOR
    AND #$01 ;CHECK 1
    CMP #$01
    BEQ DRAW0
    
    SM0CLR
    LDA CHRVALCLR
    STA CHRVALTODRAW
DRAW0
    LDY CHRCOLM
    STY VeraLO
    LDY CHRROWDR
    STY VeraMID
    LDA CHRVALTODRAW
    STA VeraDAT

SHOWMEEND
    INC CHRROWCK
    INC CHRROWDR
    LDA CHRVALTODRAW
    CMP #$0D            ;DRAWING M
    BEQ CHNGREDUCTION   
    CMP #$17            ;OR W
    BEQ CHNGREDUCTION   ;CHANGE COLUMN REDUCTION (FOR SOME REASON i CANNOT FATHOM)
    ;OTHERWISE NORMAL BACKUP
    LDA CHRCOLM
    SBC #$0E
    JMP ADVANCECOLUMN
    
    CHNGREDUCTION
    LDA CHRCOLM
    SBC #$0E 
    JMP ADVANCECOLUMN
    
    ADVANCECOLUMN
    STA CHRCOLM
    LDA CHRROWCK
    CMP charend;MYNUM1;#$10
    BEQ ENDUS
    JMP AGAIN

ENDUS
RTS

;draw gameover
    Drawgameover
    LDX #$16 ;WHICH ROW ON SCREEN TO START DRAWING
    STX CHRROWDR
    STX CHRVAL3
    LDX #$04 ;WHICH COLUMN TO START DRAWING ON 
    STX CHRCOLM
    LDX #$00 ;LETTER TO SHOW FROM LABELENGTH TO USE, OFFSET FROM START OF LABEL
    STX charstart
    STX CHRVAL2
    LDX #$00 
    STX CHRVAL4 ; INDEX OF WORD
    
    DT2GameOver
    LDA LabelGameOver,X
    STA charstart 
    ;STY CHRCOLM
    JSR DRAWCHAR
    LDA CHRCOLM ;column WE'RE NOW SITTING AT
    ADC #$0F ; ADD 2 MORE COLUMNS
    STA CHRCOLM; NEW COLUMN TO START
    INC CHRVAL4 ;INCREASE LETTER
    LDA CHRVAL4
    CMP #$09 ;WE HIT THE LENGTH OF THIS phrase
    BEQ ENDDRAWGAMEOVER ;CONTINUE IF WE'RE AT LAST LETTER
    LDX CHRVAL3
    STX CHRROWDR
    TAX
    ;LDX CHRVAL2; PUT THE NEXT LETTER INDEX INTO X
    JMP DT2GameOver ; OTHErWISE DRAW NEXT LETTER
    ENDDRAWGAMEOVER
    RTS

    DRAWReason
    LDX GMOVERRSN
    CPX #$02
    BEQ DrawHitSelf
    CPX #$03
    BEQ DrawHitBlockA
    jmp Drawhitwall

    DrawHitBlockA
    jmp DrawHitBlock ; branch would be to far for a BEQ so jumping

    ;draw hit wall
    Drawhitwall
    LDX #$21 ;WHICH ROW ON SCREEN TO START DRAWING
    STX CHRROWDR
    STX CHRVAL3
    LDX #$04 ;WHICH COLUMN TO START DRAWING ON 
    STX CHRCOLM
    LDX #$00 ;LETTER TO SHOW FROM LABELENGTH TO USE, OFFSET FROM START OF LABEL
    STX charstart
    STX CHRVAL2
    LDX #$00 
    STX CHRVAL4 ; INDEX OF WORD
    
    DT2HitWall
    LDA LabelHitWall,X
    STA charstart 
    ;STY CHRCOLM
    JSR DRAWCHAR
    LDA CHRCOLM ;column WE'RE NOW SITTING AT
    ADC #$0F ; ADD 2 MORE COLUMNS
    STA CHRCOLM; NEW COLUMN TO START
    INC CHRVAL4 ;INCREASE LETTER
    LDA CHRVAL4
    CMP #$09 ;WE HIT THE LENGTH OF THIS phrase
    BEQ dt2hitwallend ;CONTINUE IF WE'RE AT LAST LETTER
    LDX CHRVAL3
    STX CHRROWDR
    TAX
    ;LDX CHRVAL2; PUT THE NEXT LETTER INDEX INTO X
    JMP DT2HitWall ; OTHErWISE DRAW NEXT LETTER
    dt2hitwallend
    JMP ENDDRAWREASON 

DrawHitSelf
    ;draw hit self
    LDX #$21 ;WHICH ROW ON SCREEN TO START DRAWING
    STX CHRROWDR
    STX CHRVAL3
    LDX #$04 ;WHICH COLUMN TO START DRAWING ON 
    STX CHRCOLM
    LDX #$00 ;LETTER TO SHOW FROM LABELENGTH TO USE, OFFSET FROM START OF LABEL
    STX charstart
    STX CHRVAL2
    LDX #$00 
    STX CHRVAL4 ; INDEX OF WORD
    
    DT2HitSelf
    LDA LabelHitSelf,X
    STA charstart 
    ;STY CHRCOLM
    JSR DRAWCHAR
    LDA CHRCOLM ;column WE'RE NOW SITTING AT
    ADC #$0F ; ADD 2 MORE COLUMNS
    STA CHRCOLM; NEW COLUMN TO START
    INC CHRVAL4 ;INCREASE LETTER
    LDA CHRVAL4
    CMP #$09 ;WE HIT THE LENGTH OF THIS phrase
    BEQ ENDDRAWREASON; next step is PUSHSTACKPREP ;CONTINUE IF WE'RE AT LAST LETTER
    LDX CHRVAL3
    STX CHRROWDR
    TAX
    ;LDX CHRVAL2; PUT THE NEXT LETTER INDEX INTO X
    JMP DT2HitSelf ; OTHErWISE DRAW NEXT LETTER
    
;draw hit block
    DrawHitBlock
    LDX #$21 ;WHICH ROW ON SCREEN TO START DRAWING
    STX CHRROWDR
    STX CHRVAL3
    LDX #$04 ;WHICH COLUMN TO START DRAWING ON 
    STX CHRCOLM
    LDX #$00 ;LETTER TO SHOW FROM LABELENGTH TO USE, OFFSET FROM START OF LABEL
    STX charstart
    STX CHRVAL2
    LDX #$00 
    STX CHRVAL4 ; INDEX OF WORD
    
    DT2HitBlock
    LDA LabelHitblock,X
    STA charstart 
    ;STY CHRCOLM
    JSR DRAWCHAR
    LDA CHRCOLM ;column WE'RE NOW SITTING AT
    ADC #$0F ; ADD 2 MORE COLUMNS
    STA CHRCOLM; NEW COLUMN TO START
    INC CHRVAL4 ;INCREASE LETTER
    LDA CHRVAL4
    CMP #$09 ;WE HIT THE LENGTH OF THIS phrase
    BEQ ENDDRAWREASON ;CONTINUE IF WE'RE AT LAST LETTER
    LDX CHRVAL3
    STX CHRROWDR
    TAX
    ;LDX CHRVAL2; PUT THE NEXT LETTER INDEX INTO X
    JMP DT2HitBlock ; OTHErWISE DRAW NEXT LETTER
    JMP ENDDRAWREASON





    ENDDRAWREASON
    RTS

    TITLESCREEN 
    LDA GMSTATE
    CMP #$01
    BNE TSGO
    JMP SETUP2
    TSGO
    MYCOUNTER  = $4001
    MYOFFSETLO = $4002
    MYOFFSETHI = $4003
    MYX        = $4004
    MYY        = $4005
    
    LDX #$00        ;configuring starting point with all zeros
    STX MYCOUNTER   ;this will basically count all the characters being drawn
    STX MYOFFSETLO  ;this will iterate from zero to FF over and over until full screen is drawn
    STX MYX         ;setting x, which is the column to draw, to 00 to start
    STX MYY         ;and y is also zero (veramid)
    LDX #$50        
    STX MYOFFSETHI  ;Make high byte 20
    
    TSDRAW1
    LDY MYOFFSETLO    ;we need to load y with the lo byte for transferring data 
    STY $B4           ;b4 is the zero byte location we'll look at for screen data
    LDY MYOFFSETHI    ;and now we load y with the hi byte for transferring data
    STY $B5           ;b5 is where we'll handle this, advancing it every time b4 reaches FF
    
    LDX #$00          ;I'll always be looking at b4, so indirect addressing using X at 0 is all we need
    LDA ($B4,X)       ;between b4 and b5 we'll have the location of ever screen element by iterating through

    LDX MYX             ;We now set up the draw routine for Vera
    STX VERALO          ;set lo byte to MYX
    LDX MYY             ;load the column into MYY
    STX VERAMID         ;and set high byte to MYY  
    STA VERADAT         ;then we use the accumulator value, which is essentially the value at $2000 + Counter as stored at b4 and b5
    INC MYX             ;now that we increase the column
    INC MYX             ;by 2 since we aren't dealing with color
    INC MYCOUNTER       ;and increase the counter
    INC MYOFFSETLO      ;INCREASE the value at b4 (lo)

    LDX MYX             ;since we need to watch out for end of row, we check MYX
    CPX #$A0            ;to see when we hit 160 
    BNE XXXXXXXXX       ;if we haven't yet hit 160, we're going to keep drawing, but do have to deal with the counter hitting #$FF
    INC MYY             ;since we hit 160 we need to increase the row (MYY)
    LDX #$00            ;then prep X to reset column to 0
    STX MYX             ;and change the column
    
    LDX MYY
    CPX #$30            ;height of screen
    BNE XXXXXXXXX
    JMP TSCOLOR

    XXXXXXXXX
    LDX MYCOUNTER
    CPX #$00
    BNE YYYYYYYYY
    LDX MYX             ;We now set up the draw routine for Vera
    STX VERALO          ;set lo byte to MYX
    LDX MYY             ;load the column into MYY
    STX VERAMID         ;and set high byte to MYY  
    LDX #$00
    LDA ($B4,X)       ;between b4 and b5 we'll have the location of ever screen element by iterating through
    STA VERADAT         ;then we use the accumulator value, which is essentially the value at $2000 + Counter as stored at b4 and b5
    
    LDX #$00
    STX MYCOUNTER
    INC MYOFFSETHI
    LDX MYOFFSETHI
    CPX #$63
    BEQ TSCOLOR

    YYYYYYYYY
    JMP TSDRAW1

TSCOLOR
    LDX #$01        ;starting on second column for colors
    STX MYX
    LDX #$00        ;FOR COLORS, OUR START POINT IS DIFFERNET $3310
    STX MYOFFSETLO
    STX MYCOUNTER   ;this will basically count all the characters being drawn
    STX MYY         ;and y is also zero (veramid)
    LDX #$60        
    STX MYOFFSETHI  ;Make high byte 60
    
    TSCOLOR1
    LDY MYOFFSETLO    ;we need to load y with the lo byte for transferring data 
    STY $B4           ;b4 is the zero byte location we'll look at for screen data
    LDY MYOFFSETHI    ;and now we load y with the hi byte for transferring data
    STY $B5           ;b5 is where we'll handle this, advancing it every time b4 reaches FF
    
    LDX #$00          ;I'll always be looking at b4, so indirect addressing using X at 0 is all we need
    LDA ($B4,X)       ;between b4 and b5 we'll have the location of ever screen element by iterating through

    LDX MYX             ;We now set up the draw routine for Vera
    STX VERALO          ;set lo byte to MYX
    LDX MYY             ;load the column into MYY
    STX VERAMID         ;and set high byte to MYY  
    STA VERADAT         ;then we use the accumulator value, which is essentially the value at $2000 + Counter as stored at b4 and b5
    INC MYX             ;now that we increase the column
    INC MYX             ;by 2 since we aren't dealing with color
    INC MYCOUNTER       ;and increase the counter
    INC MYOFFSETLO      ;INCREASE the value at b4 (lo)

    LDX MYX             ;since we need to watch out for end of row, we check MYX
    CPX #$A1            ;to see when we hit 161
    BNE XXXXXXXXX1       ;if we haven't yet hit 161, we're going to keep drawing, but do have to deal with the counter hitting #$FF
    INC MYY             ;since we hit 160 we need to increase the row (MYY)
    LDX #$01            ;then prep X to reset column to 1
    STX MYX             ;and change the column
    
    LDX MYY
    CPX #$30            ;height of screen
    BNE XXXXXXXXX1
    JMP ENDTITLE

    XXXXXXXXX1
    LDX MYCOUNTER
    CPX #$00
    BNE YYYYYYYYY1
    LDX MYX             ;We now set up the draw routine for Vera
    STX VERALO          ;set lo byte to MYX
    LDX MYY             ;load the column into MYY
    STX VERAMID         ;and set high byte to MYY  
    LDX #$00
    LDA ($B4,X)       ;between b4 and b5 we'll have the location of ever screen element by iterating through
    STA VERADAT         ;then we use the accumulator value, which is essentially the value at $2000 + Counter as stored at b4 and b5
    
    ;LDX #$00
    ;STX MYCOUNTER
    INC MYOFFSETHI
    LDX MYOFFSETHI
    CPX #$73
    BEQ ENDTITLE

    YYYYYYYYY1
    JMP TSCOLOR1

    ENDTITLE
    JMP CHECKKEY
    RTS

.org $5000
TROW00  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW01  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW02  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW03  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW04  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,23,5,12,3,15,13,5,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW05  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW06  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,20,15,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW07  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW08  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,160,160,160,160,32,32,160,160,32,32,160,160,   32, 32, 32,160,160, 32, 32, 32,160,160, 32, 32,160,160, 32,160,160,160,160,160, 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW09  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,160,160,32,32,160,160,32,160,160,160,32,160,160,  32, 32,160,160,160,160, 32, 32,160,160, 32,160,160, 32, 32,160,160, 32, 32, 32, 32, 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW10  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,160,160,32,32,32,32,32,160,160,160,160,160,160,   32,160,160, 32, 32,160,160, 32,160,160,160,160, 32, 32, 32,160,160, 32, 32, 32, 32, 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW11  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,160,160,160,160,32,32,160,160,160,160,160,160, 32,160,160,160,160,160,160, 32,160,160,160, 32, 32, 32, 32,160,160,160,160, 32, 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW12  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,160,160,32,160,160,32,160,160,160,    32,160,160, 32, 32,160,160, 32,160,160,160,160, 32, 32, 32,160,160, 32, 32, 32, 32, 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW13  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,160,160,32,32,160,160,32,160,160,32,32,160,160,   32,160,160, 32, 32,160,160, 32,160,160, 32,160,160, 32, 32,160,160, 32, 32, 32, 32, 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW14  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,160,160,160,160,32,32,160,160,32,32,160,160,   32,160,160, 32, 32,160,160, 32,160,160, 32, 32,160,160, 32,160,160,160,160,160, 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW15  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW16  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW17  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,1,32,3,15,13,13,1,14,4,5,18,32,24,49,54,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW18  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW29  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,1,19,19,5,13,2,12,25,32,12,1,14,7,21,1,7,5,32,16,18,15,10,5,3,20,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW20  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW21  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW22  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,2,25,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW23  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW24  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,10,15,8,14,32,8,15,6,6,5,18,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW25  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW26  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,00,10,15,8,14,14,23,6,19,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW27  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW38  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW39  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,23,18,9,20,20,5,14,32,6,15,18,32,20,8,5,32,5,13,21,12,1,20,15,18,32,22,51,51,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW30  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW31  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW32  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW33  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,95,160,160,223,32,32,32,233,160,160,105,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW34  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,95,160,160,223,32,233,160,160,105,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW35  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,95,160,160,32,160,160,105,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW36  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,160,32,160,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW47  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,233,160,160,32,160,160,223,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW48  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,233,160,160,105,32,95,160,160,223,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW49  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,233,160,160,105,32,32,32,95,160,160,223,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW40  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW41  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW42  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW43  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW44  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,16,18,05,19,19,32,19,16,01,03,05,32,20,15,32,19,20,01,18,20,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW45  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW56  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW57  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW58  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW59  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW50  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW51  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW52  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW53  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW54  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW65  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW66  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW67  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW68  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW69  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
TROW60  .byte 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
.org $6000
TRIW00 .byte  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW01  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW02  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW03  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW04  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW05  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW06  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW07  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW08  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  1,  4,  4,  4,  4,  1,  1,  4,  4,  1,  1,  4,  4,  1,  1,  1,  4,  4,  1,  1,  1,  4,  4,  1,  1,  4,  4,  1,  4,  4,  4,  4,  4, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW09  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 14, 14,  1,  1, 14, 14,  1, 14, 14, 14,  1, 14, 14,  1,  1, 14, 14, 14, 14,  1,  1, 14, 14,  1, 14, 14,  1,  1, 14, 14,  1,  1,  1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW10  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  3,  3,  1,  1,  1,  1,  1,  3,  3,  3,  3,  3,  3,  1,  3,  3,  1,  1,  3,  3,  1,  3,  3,  3,  3,  3,  1,  1,  3,  3,  1,  1,  1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW11  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  1,101,101,101,101,  1,  1,101,101,101,101,101,101,  1,101,101,101,101,101,101,  1,101,101,101,  1,  1,  1,  1,101,101,101,101,  1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW12  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  1,  1,  1,  7,  7,  7,  1,  7,  7,  1,  7,  7,  7,  1,  7,  7,  1,  1,  7,  7,  1,  7,  7,  7,  7,  1,  1,  1,  7,  7,  1,  1,  1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW13  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  8,  8,  1,  1,  8,  8,  1,  8,  8,  1,  1,  8,  8,  1,  8,  8,  1,  1,  8,  8,  1,  8,  8,  1,  8,  8,  1,  1,  8,  8,  1,  1,  1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW14  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  1,  2,  2,  2,  2,  1,  1,  2,  2,  1,  1,  2,  2,  1,  2,  2,  1,  1,  2,  2,  1,  2,  2,  1,  1,  2,  2,  1,  2,  2,  2,  2,  2, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW15  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW16  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW17  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW18  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW29  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW20  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW21  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW22  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW23  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW24  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW25  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW26  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW27  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW38  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW39  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW30  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW31  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW32  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW33  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4,4,4,4,1,1,1,    4,4,4,4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW34  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,14,14,14,14,1,14,14,14,14,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW35  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,3,3,1,    3,3,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW36  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,101,1,101,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW47  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,7,7,7,1,    7,7,7,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW48  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,8,8,8,8,1,    8,8,8,8,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW49  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,1,1,    1,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW40  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW41  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW42  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW43  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW44  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW45  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW56  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW57  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW58  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW59  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW50  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW51  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW52  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW53  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW54  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW65  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW66  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW67  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW68  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW69  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
TRIW60  .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
