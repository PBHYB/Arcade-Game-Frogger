#####################################################################
#
# CSC258H5S Fall 2021 Assembly Final Project
# University of Toronto, St. George
#
# Student: Yanbin Huang 1006345616
#
# Bitmap Display Configuration:
# - Unit width in pixels: 16
# - Unit height in pixels: 16
# - Display width in pixels: 512
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 5 (choose the one the applies)
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Display a death/respawn animation each time the player loses a frog.
# 2. Add a third row in each of the water and road sections.
# 3. Have objects in different rows move at different speeds.
# 4. After final player death, display gameover/retry screen. Restart the game if the¡°retry¡± option is chosen.
# 5. Display the number of lives remaining. 
# 6. Add sound effects for movement,collisions, game end and reaching the goal area.

# Any additional information that the TA needs to know:
# - Restar option: press white space to restart the game any time while you in a game end state or win state.
# - Go to ShiftLogs1, ShiftLogs2 and Move1 Move 2 etc to set up the speed you want, or go to DrawFrog to set up the sleeping time.
# This may be helpful for testing the functionality of the game.
#####################################################################

.data
displayAddress: .word 0x10008000 # the address of the first pixel of our drawing
frogX: .word 0          # the X location of the frog
frogY: .word 0          # the Y location of the frog
#                          watercolor(0)           safeZoneColor(4)        black(8)         purple(12)      carGrey(16)       logcolor(20)       Yellow(24)          poision(28)       White(32)         Red(36)
color: .word                0x0000ccff              0x0049c214         0x00000000        0x00880aff        0x00bcbcbc      0x00ba8c63            0x00de9f07          0x007F2152        0x00ffffff       0xfd0707  
vehicle1:  .space 256 # save room for the first vehicle row 
vehicle2:  .space 256 # save room for the second vehicle row 
vehicle3:  .space 256 # save room for the second vehicle row 
logs1: .space 384    # save room for the first log row 
logs2: .space 384    # save room for the second log row  
logs3: .space 256    # save room for the second log row

.text
lw $t0, displayAddress # $t0 stores the base address for display
la $t1, color          # $t1 stores the adress of the color
li $t8, 0xffff0000	
li $s7, 0 # program counter






# put lives and points into stack
SetStack: li $s1, 0 # initiate the points to 0
          li $s2, 3 # initiate the lives to three
          addi $sp, $sp, -4 # goal 1
          sw $s1, 0($sp)
          addi $sp, $sp, -4 # goal 2
          sw $s1, 0($sp)
          addi $sp, $sp, -4 # goal 3
          sw $s1, 0($sp)
          addi $sp, $sp, -4 # goal 4
          sw $s1, 0($sp)
          addi $sp, $sp, -4 # goal 5
          sw $s1, 0($sp)
          addi $sp, $sp, -4 # points
          sw $s1, 0($sp)
          addi $sp, $sp, -4 #lives
          sw $s2, 0($sp)

# initialize the rows of obstacles

#load vehicle1
SetPixels1:  la $t9, vehicle1
             la $s1, vehicle1 
             addi $t9, $t9, 256       
             addi $s2, $zero, 0
             addi $s2, $t0, 2560
             jal SavePixels
             
#load vehicle2          
SetPixels2:  la $t9, vehicle2   
             la $s1, vehicle2
             addi $t9, $t9, 256
             addi $s2, $zero, 0
             addi $s2, $t0, 2944
             jal SavePixels
             
#load vehicle2            
SetPixels3:  la $t9, vehicle3   
             la $s1, vehicle3
             addi $t9, $t9, 256
             addi $s2, $zero, 0
             addi $s2, $t0, 3328
             jal SavePixels   
        
#load logs1                   
SetPixels4: la $t9, logs1
             la $s1, logs1
             addi $t9, $t9, 384
             addi $s2, $zero, 0
             addi $s2, $t0, 1024
             jal SavePixels

#load logs2
SetPixels5:  la $t9, logs2   
             la $s1, logs2
             addi $t9, $t9, 384
             addi $s2, $zero, 0
             addi $s2, $t0, 1408
             jal SavePixels

#load logs3
SetPixels6:  la $t9, logs3   
             la $s1, logs3
             addi $t9, $t9, 256
             addi $s2, $zero, 0
             addi $s2, $t0, 1792
             jal SavePixels
             j DrawSafeZone            

#save the pixels into the memory
SavePixels:   bge $s1, $t9, GoBack           
              sw $s2, 0($s1)
              addi $s1, $s1, 4
              addi $s2, $s2, 4
              j SavePixels
              
# go back and excute next line
GoBack:jr $ra         
          
# Clean the program
ClearLocation:  addi $s0, $zero, 0
                addi $s1, $zero, 0
                sw $s1, frogX($s0)
                sw $s1, frogY($s0)
ResetValue:   lw $t0, displayAddress # $t0 stores the base address for display
              la $t1, color          # $t1 stores the adress of the color
              li $t8, 0xffff0000
              j SetStack         
# Animation Parts
CollideEffect:  sw $s0, 0($s2)
                sw $s0, 8($s2)
                sw $s0, 132($s2)
                sw $s0, 256($s2)     
                sw $s0, 264($s2)
                j GoBack
                
GoalEffect:     sw $s0, 0($s2)
                sw $s0, 8($s2)
                sw $s0, 128($s2) 
                sw $s0, 132($s2)
                sw $s0, 136($s2)
                sw $s0, 256($s2)     
                sw $s0, 260($s2)
                sw $s0, 264($s2)
                sw $s0, 384($s2)
                sw $s0, 392($s2)
                jr $ra
# The end of the game
Loselives: lw $s0, 0($sp)
           addi $s0, $s0, -1
           sw $s0, 0($sp)
           jal CollideSound
           addi $s1, $zero, 3644  # the starting point of the frog
           lw $s0, 24($t1)        # load the white color 
           lw $s4, frogX          # current X location of the frog
           lw $s5, frogY          # current Y location of the frog
           add $s1, $s1, $s4
           add $s1, $s1, $s5
           add $s2, $t0, $s1
           jal CollideEffect
           sw $zero, frogX($zero)
           sw $zero, frogY($zero)
           li $v0, 32
           li $a0, 1000
           syscall
           j DrawSafeZone
       
WinState: lw $s0, 36($t1)
          addi $s1, $t0, 1556
          
          sw $s0, 0($s1) # W
          sw $s0, 128($s1)
          sw $s0, 256($s1)
          sw $s0, 384($s1)
          sw $s0, 396($s1)
          sw $s0, 496($s1)
          sw $s0, 500($s1)
          sw $s0, 512($s1)
          sw $s0, 520($s1)
          sw $s0, 640($s1)
          sw $s0, 648($s1)
          sw $s0, 768($s1)
          sw $s0, 772($s1)
          sw $s0, 896($s1)
          sw $s0, 24($s1) 
          sw $s0, 152($s1)
          sw $s0, 280($s1)
          sw $s0, 408($s1)
          sw $s0, 536($s1)
          sw $s0, 528($s1)
          sw $s0, 664($s1)
          sw $s0, 656($s1)
          sw $s0, 792($s1)
          sw $s0, 788($s1)
          sw $s0, 920($s1)
          
          addi $s1, $s1, 32
          sw $s0, 12($s1) # I
          sw $s0, 268($s1)
          sw $s0, 396($s1)
          sw $s0, 524($s1)
          sw $s0, 652($s1)
          sw $s0, 780($s1)
          sw $s0, 908($s1)
          
          
          addi $s1, $s1, 16
          sw $s0, 12($s1) # n
          sw $s0, 16($s1)
          sw $s0, 20($s1)
          sw $s0, 24($s1)
          sw $s0, 28($s1)
          sw $s0, 140($s1)
          sw $s0, 268($s1)
          sw $s0, 396($s1)
          sw $s0, 524($s1)
          sw $s0, 652($s1)
          sw $s0, 780($s1)
          sw $s0, 908($s1)
          addi $s1, $s1, 20
          sw $s0, 12($s1) 
          sw $s0, 140($s1)
          sw $s0, 268($s1)
          sw $s0, 396($s1)
          sw $s0, 524($s1)
          sw $s0, 536($s1)
          sw $s0, 540($s1)
          sw $s0, 652($s1)
          sw $s0, 780($s1)
          sw $s0, 908($s1)
          
          lw $s2, 4($t8) # press space to restart
          beq $s2, 0x20, respond_to_space	
          
          li $v0, 32
          li $a0, 1000
          syscall
          j WinState
           
GameOver: lw $s0, 32($t1)
          addi $s1, $t0, 1576
          
          sw $s0, 0($s1) # G1
          sw $s0, 4($s1)
          sw $s0, 8($s1)
          sw $s0, 12($s1)
          sw $s0, 16($s1)
          sw $s0, 128($s1)
          sw $s0, 256($s1)
          sw $s0, 384($s1)
          sw $s0, 512($s1)
          sw $s0, 640($s1)
          sw $s0, 768($s1)
          sw $s0, 772($s1)
          sw $s0, 776($s1)
          sw $s0, 780($s1)
          sw $s0, 784($s1)
          sw $s0, 400($s1)
          sw $s0, 528($s1)
          sw $s0, 656($s1)
          sw $s0, 396($s1)
          sw $s0, 392($s1)
          sw $s0, 372($s1)
          sw $s0, 376($s1)
          
          addi $s1, $s1, 32
          sw $s0, 0($s1) # G2
          sw $s0, 4($s1)
          sw $s0, 8($s1)
          sw $s0, 12($s1)
          sw $s0, 16($s1)
          sw $s0, 128($s1)
          sw $s0, 256($s1)
          sw $s0, 384($s1)
          sw $s0, 512($s1)
          sw $s0, 640($s1)
          sw $s0, 768($s1)
          sw $s0, 772($s1)
          sw $s0, 776($s1)
          sw $s0, 780($s1)
          sw $s0, 784($s1)
          sw $s0, 400($s1)
          sw $s0, 528($s1)
          sw $s0, 656($s1)
          sw $s0, 396($s1)
          sw $s0, 392($s1)
          sw $s0, 408($s1)
          sw $s0, 412($s1)
          
          lw $s2, 4($t8) # press space to restart
          beq $s2, 0x20, respond_to_space	
          
          jal GameEndSound
          
          li $v0, 32
          li $a0, 1000
          syscall
          j GameOver
          
                         
# Collition detection
CheckLives:       lw $s0, 0($sp)  # load current lives
                  ble $s0, 0, GameOver
                  
CheckWin:         addi $sp, $sp, 4
                  lw $s0, 0($sp)
                  addi $sp, $sp, -4
                  beq $s0, 5, WinState
       
CollideWithCars:  lw $s0, frogY
                  lw $s1, frogX
                  lw $s4, 16($t1)
                  add $s2, $s0, $s1
                  addi $s2, $s2, 3644 # get the leftmost pixels address of the frog 
                  add $s2, $s2, $t0
                  lw $s3, 0($s2)     # check the first pixels collide or not
                  beq $s3,$s4,Loselives
                  lw $s3, 4($s2)
                  beq $s3,$s4,Loselives
                  lw $s3, 8($s2)
                  beq $s3,$s4,Loselives
                  lw $s3, 128($s2)
                  beq $s3,$s4,Loselives
                  lw $s3, 136($s2)
                  beq $s3,$s4,Loselives
                  lw $s3, 256($s2)
                  beq $s3,$s4,Loselives
                  lw $s3, 264($s2)
                  beq $s3,$s4,Loselives
                  lw $s3, 384($s2)
                  beq $s3,$s4,Loselives
                  lw $s3, 388($s2)
                  beq $s3,$s4,Loselives
                  lw $s3, 392($s2)
                  beq $s3,$s4,Loselives        
                    
CollideWithWater: lw $s0, frogY
                  lw $s1, frogX
                  lw $s4, 0($t1)
                  add $s2, $s0, $s1
                  addi $s2, $s2, 3644 # get the leftmost pixels address of the frog 
                  add $s2, $s2, $t0
                  lw $s3, 128($s2)  # check the middle pixels collide or not
                  beq $s3,$s4,Loselives
                  lw $s3, 132($s2)
                  beq $s3,$s4,Loselives
                  lw $s3, 136($s2)
                  beq $s3,$s4,Loselives
                  lw $s3, 256($s2)
                  beq $s3,$s4,Loselives
                  lw $s3, 260($s2)
                  beq $s3,$s4,Loselives
                  lw $s3, 264($s2)
                  beq $s3,$s4,Loselives
                  
CollideWithPosion:lw $s0, frogY
                  lw $s1, frogX
                  lw $s4, 28($t1)
                  add $s2, $s0, $s1
                  addi $s2, $s2, 3644 # get the leftmost pixels address of the frog 
                  add $s2, $s2, $t0
                  lw $s3, 128($s2)  # check the middle pixels collide or not
                  beq $s3,$s4,Loselives
                  lw $s3, 132($s2)
                  beq $s3,$s4,Loselives
                  lw $s3, 136($s2)
                  beq $s3,$s4,Loselives
                  lw $s3, 256($s2)
                  beq $s3,$s4,Loselives
                  lw $s3, 260($s2)
                  beq $s3,$s4,Loselives
                  lw $s3, 264($s2)
                  beq $s3,$s4,Loselives
                  
CollideWithLogs:  lw $s0, frogY
                  lw $s1, frogX
                  lw $s4, 20($t1)
                  add $s2, $s0, $s1
                  addi $s2, $s2, 3644 # get the leftmost pixels address of the frog 
                  add $s2, $s2, $t0
                  lw $s3, 128($s2)  # check the middle pixels collide or not
                  beq $s3,$s4,CheckWhichRow
                  j CollideWithGoal
CheckWhichRow:    lw $s0, frogY
                  lw $s1, frogX
                  add $s2, $s0, $s1
                  addi $s2, $s2, 3772 # get the address of the middle pixels
                  bge $s2,1024, Check1
                  bge $s2, 1408, Check2
                  bge $s2, 1792, Check3
Check1: ble $s2, 1404, Move1
Check2: ble $s2, 1788, Move2  
Check3: ble $s2, 2044, Move3                  
                  
CollideWithGoal:  lw $s0, frogY
                  addi $s1, $zero, 640
                  addi $s0,$s0, 3644
                  blt $s0, $s1, MarkDone
                  j DrawFrog
                  
MarkDone:      addi $sp, $sp, 4
               lw $s0, 0($sp)
               addi $s0, $s0, 1 # add one point
               sw $s0, 0($sp)
               addi $sp, $sp, -4
               
               addi $s1, $zero, 3644  # the starting point of the frog
               lw $s0, 32($t1)        # load the color of safe zone to $s0
               lw $s4, frogX          # current X location of the frog
               lw $s5, frogY          # current Y location of the frog
               add $s1, $s1, $s4
               add $s1, $s1, $s5
               add $s2, $t0, $s1
               add $s3, $t0, 536
               blt $s2, $s3, Position1
               addi $s3, $s3, 24
               blt $s2, $s3, Position2
               addi $s3, $s3, 24
               blt $s2, $s3, Position3
               addi $s3, $s3, 24
               blt $s2, $s3, Position4
               addi $s3, $s3, 24
               blt $s2, $s3, Position5
               
               
              

               
# Positions
Position1:     jal GoalEffect
               jal GoalSound
               addi $sp, $sp, 24
               lw  $s0, 0($sp)
               addi $s0, $zero, 1  # set position 1 to 1
               sw $s0, 0($sp)
               addi $sp, $sp, -24   
               sw $zero, frogX($zero)          # swt to 0
               sw $zero, frogY($zero)          # set to 0
               li $v0, 32
               li $a0, 1000
               syscall                     
               j DrawSafeZone  
               
Position2:     jal GoalEffect
               jal GoalSound
               addi $sp, $sp, 28
               lw  $s0, 0($sp)
               addi $s0, $zero, 1  # set position 1 to 1
               sw $s0, 0($sp)
               addi $sp, $sp, -28   
               sw $zero, frogX($zero)          # swt to 0
               sw $zero, frogY($zero)          # set to 0
               li $v0, 32
               li $a0, 1000
               syscall                     
               j DrawSafeZone   
               
Position3:     jal GoalEffect
               jal GoalSound
               addi $sp, $sp, 32
               lw  $s0, 0($sp)
               addi $s0, $zero, 1  # set position 1 to 1
               sw $s0, 0($sp)
               addi $sp, $sp, -32   
               sw $zero, frogX($zero)          # swt to 0
               sw $zero, frogY($zero)          # set to 0
               li $v0, 32
               li $a0, 1000
               syscall                     
               j DrawSafeZone 
               
Position4:     jal GoalEffect
               jal GoalSound
               addi $sp, $sp, 36
               lw  $s0, 0($sp)
               addi $s0, $zero, 1  # set position 1 to 1
               sw $s0, 0($sp)
               addi $sp, $sp, -36   
               sw $zero, frogX($zero)          # swt to 0
               sw $zero, frogY($zero)          # set to 0
               li $v0, 32
               li $a0, 1000
               syscall                     
               j DrawSafeZone         
                      
Position5:     jal GoalEffect
               jal GoalSound
               addi $sp, $sp, 40
               lw  $s0, 0($sp)
               addi $s0, $zero, 1  # set position 1 to 1
               sw $s0, 0($sp)
               addi $sp, $sp, -40   
               sw $zero, frogX($zero)          # swt to 0
               sw $zero, frogY($zero)          # set to 0
               li $v0, 32
               li $a0, 1000
               syscall                     
               j DrawSafeZone 
                                                                                                                                                                           
# Moving the frog with logs
Move1:         la $s0, frogX
               addi $a0, $zero, 50 # set up different speed
               div $s7, $a0
               mfhi $a0
               bne $a0, $zero,DrawFrog
               addi $s1,$s1, 4
               bge $s1, 68, RoundFrog1
               sw $s1, 0($s0)
               j DrawFrog
Move2:         la $s0, frogX
               addi $a0, $zero, 30 # set up different speed
               div $s7, $a0
               mfhi $a0
               bne $a0, $zero,DrawFrog
               addi $s1,$s1, -4
               ble $s1, -64, RoundFrog2
               sw $s1, 0($s0)
               j DrawFrog
Move3:         la $s0, frogX
               addi $a0, $zero, 20 # set up different speed
               div $s7, $a0
               mfhi $a0
               bne $a0, $zero,DrawFrog
               addi $s1,$s1, 4
               bge $s1, 68, RoundFrog1
               sw $s1, 0($s0)
               j DrawFrog                                                                                                                                                                                         
RoundFrog1:addi $t9, $zero, -60
           sw $t9, 0($s0)
           j DrawFrog
RoundFrog2: addi $t9, $zero, 56
           sw $t9, 0($s0)
           j DrawFrog
j DrawFrog                                                                                                                                                                                                                                                                                                                                                                           
# Safe zone: 0 to 1020; Water zone: 1024 to 2044; Riverside: 2048 to 2556; Road: 2560 to 3580; Base Line: 3584 to 4092

DrawHHp:      lw $s0, 32($t1)
              addi $s2, $t0, 0 # load the starting point
              sw $s0, 0($s2)
              sw $s0, 132($s2)
              sw $s0, 8($s2)
              sw $s0, 16($s2)
              sw $s0, 148($s2)
              sw $s0, 24($s2)
              sw $s0, 32($s2)
              sw $s0, 164($s2)
              sw $s0, 40($s2)
              j DrawBoundary
              
DrawMHp:      lw $s0, 32($t1)
              addi $s2, $t0, 0 # load the starting point
              sw $s0, 0($s2)
              sw $s0, 132($s2)
              sw $s0, 8($s2)
              sw $s0, 16($s2)
              sw $s0, 148($s2)
              sw $s0, 24($s2)
              j DrawBoundary
              
DrawLHp:      lw $s0, 32($t1)
              addi $s2, $t0, 0 # load the starting point
              sw $s0, 0($s2)
              sw $s0, 132($s2)
              sw $s0, 8($s2)
              j DrawBoundary
              
DrawBlock: sw $s0, 0($s1)
           sw $s0, 4($s1)
           sw $s0, 8($s1)
           sw $s0, 12($s1)
           sw $s0, 16($s1)
           sw $s0, 128($s1)
           sw $s0, 132($s1)
           sw $s0, 136($s1)
           sw $s0, 140($s1)
           sw $s0, 144($s1)
           sw $s0, 256($s1)
           sw $s0, 260($s1)
           sw $s0, 264($s1)
           sw $s0, 268($s1)
           sw $s0, 272($s1)
           sw $s0, 384($s1)
           sw $s0, 388($s1)
           sw $s0, 392($s1)
           sw $s0, 396($s1)
           sw $s0, 400($s1)
           jr $ra
              
Drawer:  bgt $s1, $s2, GoBack # Drawer used to draw the background
         sw $s0, 0($s1) 
         addi $s1, $s1, 4
         j Drawer     
         
DrawVLine: sw $s0, 0($s1)
           sw $s0, 128($s1)
           sw $s0, 256($s1)
           sw $s0, 384($s1)
           jr $ra  
             
DrawSafeZone: addi $s1, $t0, 0      # set $s1 to the point where Safe zone begins and draw safe zone area
              lw $s0, 4($t1)        # load the color of safe zone to $s0
              addi $s2, $t0, 1020 # load the end point of the safe zone
              jal Drawer

DrawHp:      lw $s0, 0($sp)
             beq $s0, 1, DrawLHp
             beq $s0, 2, DrawMHp
             beq $s0, 3, DrawHHp           
              
DrawBoundary: addi $s1, $t0, 384      # set $s1 to the point where Safe zone begins and draw safe zone area
              lw $s0, 28($t1)        # load the color of safe zone to $s0
              addi $s2, $t0, 508
              jal Drawer
              addi $s1, $t0, 512
              jal DrawVLine
              addi $s1, $t0, 536
              jal DrawVLine
              addi $s1, $t0, 560
              jal DrawVLine
              addi $s1, $t0, 584
              jal DrawVLine
              addi $s1, $t0, 608
              jal DrawVLine
              addi $s1, $t0, 632
              jal DrawVLine
              addi $s1, $t0, 636
              jal DrawVLine
              
CheckPosition1: addi $sp, $sp, 24
               lw  $s0, 0($sp)
               addi $sp, $sp, -24
               beq $s0, 1, DrawPosition1
CheckPosition2:
               addi $sp, $sp, 28
               lw  $s0, 0($sp)
               addi $sp, $sp, -28
               beq $s0, 1, DrawPosition2
CheckPosition3:
               addi $sp, $sp, 32
               lw  $s0, 0($sp)
               addi $sp, $sp, -32
               beq $s0, 1, DrawPosition3
CheckPosition4:
               addi $sp, $sp, 36
               lw  $s0, 0($sp)
               addi $sp, $sp, -36
               beq $s0, 1, DrawPosition4
CheckPosition5:
               addi $sp, $sp, 40
               lw  $s0, 0($sp)
               addi $sp, $sp, -40
               beq $s0, 1, DrawPosition5
               j DrawWater

DrawPosition1: addi $s1, $t0, 516    # set $s1 to the point where Position begins and draw riverside area
               lw $s0, 28($t1)
               jal DrawBlock
               j CheckPosition2
               
DrawPosition2: addi $s1, $t0, 540    # set $s1 to the point where Position begins and draw riverside area
               lw $s0, 28($t1)
               jal DrawBlock
               j CheckPosition3
               
DrawPosition3: addi $s1, $t0, 564    # set $s1 to the point where Position begins and draw riverside area
               lw $s0, 28($t1)
               jal DrawBlock
               j CheckPosition4
               
DrawPosition4: addi $s1, $t0, 588    # set $s1 to the point where Position begins and draw riverside area
               lw $s0, 28($t1)
               jal DrawBlock
               j CheckPosition5
               
DrawPosition5: addi $s1, $t0, 612    # set $s1 to the point where Position begins and draw riverside area
               lw $s0, 28($t1)
               jal DrawBlock
               j DrawWater

DrawWater:    addi $s1, $t0, 1024    # set $s1 to the point where Water begins and draw water area
              lw $s0, 0($t1)         # load the color of water to $s0
              addi $s2, $t0, 2044    # load the end point of the water
              jal Drawer
      
      
DrawRiverSide: addi $s1, $t0, 2048    # set $s1 to the point where Riverside begins and draw riverside area
               lw $s0, 4($t1)         # load the color of riverside to $s0
               addi $s2, $t0, 2556    # load the end point of the riverside
               jal Drawer

DrawBaseLine:  addi $s1, $t0, 3584    # set $s1 to the point where Baseline begins and draw riverside area
               lw $s0, 4($t1)         # load the color of riverside to $s0
               addi $s2, $t0, 4092    # load the end point of the riverside
               jal Drawer

DrawRoad:      addi $s1, $t0, 2560    # set $s1 to the point where Road begins and draw road area
               lw $s0, 8($t1)         # load the color of road to $s0
               addi $s2, $t0, 3580    # load the end point of the road
               jal Drawer
               
DrawCars:     lw $s0, 16($t1)         #load the color for the car
              la $t2, vehicle1        #load the address of the car row
              jal CarDrawer

DrawLogs:     lw $s0, 20($t1)         #load the color for the log
              la $t2, logs1        #load the address of the log row
              jal LogDrawer
                            
keypress_detector:  lw $s2, 4($t8)			# this assumes $t8 is set to 0xfff0000 from before
	            beq $s2, 0x77, respond_to_w	        # w in ASCII
                    beq $s2, 0x61, respond_to_a	        # a in ASCII
	            beq $s2, 0x73, respond_to_s	        # s in ASCII
	            beq $s2, 0x64, respond_to_d	        # d in ASCII
	            beq $s2, 0x20, respond_to_space	# space in ASCII
                    j CheckLives                        # no key has been pressed             
respond_to_w: lw $s1, frogY
              addi $s0, $zero, 0
              addi $s1, $s1, -384
              sw $s1, frogY($s0)
              sw $s0, 4($t8)
              jal MovingSound
              j CheckLives
respond_to_a: lw $s1, frogX
              addi $s0, $zero, 0
              addi $s1, $s1, -4
              sw $s1, frogX($s0)
              sw $s0, 4($t8)
              jal MovingSound
              j CheckLives
respond_to_s: lw $s1, frogY
              addi $s0, $zero, 0
              addi $s1, $s1, 384
              sw $s1, frogY($s0)
              sw $s0, 4($t8)
              jal MovingSound
              j CheckLives
respond_to_d: lw $s1, frogX
              addi $s0, $zero, 0
              addi $s1, $s1, 4
              sw $s1, frogX($s0)
              sw $s0, 4($t8)
              jal MovingSound
              j CheckLives
respond_to_space:addi $s0, $zero, 0
                 sw $s0, 4($t8)
                 j ClearLocation
# Draw the frog              
DrawFrog:      addi $s1, $zero, 3644  # the starting point of the frog
               lw $s0, 24($t1)        # load the color of frog to $s0
               lw $s4, frogX          # current X location of the frog
               lw $s5, frogY          # current Y location of the frog
               add $s1, $s1, $s4
               add $s1, $s1, $s5
               add $s2, $t0, $s1
               sw $s0, 128($s2)
               sw $s0, 136($s2)
               sw $s0, 260($s2)
               lw $s0, 12($t1)
               sw $s0, 0($s2)
               sw $s0, 8($s2)
               sw $s0, 132($s2)
               sw $s0, 256($s2)     
               sw $s0, 264($s2)
               sw $s0, 384($s2)
               sw $s0, 392($s2)
               li $v0, 32
               li $a0, 17
               syscall
               addi $s7, $s7, 1
     
# Set up the condiction for shifting
ShiftLogs1:   addi $t9, $zero, 384
              addi $s1, $zero, 0
              la $s3, logs1
              addi $a0, $zero, 50 # set up different speed
              div $s7, $a0
              mfhi $a0
              bne $a0, $zero, ShiftLogs2
              jal ShiftR
ShiftLogs2:   addi $t9, $zero, 384
              addi $s1, $zero, 0
              la $s3, logs2
              addi $a0, $zero, 30 # set up different speed
              div $s7, $a0
              mfhi $a0
              bne $a0, $zero, ShiftLogs3
              jal ShiftL
ShiftLogs3:   addi $t9, $zero, 256
              addi $s1, $zero, 0
              la $s3, logs3
              addi $a0, $zero, 20 # set up different speed
              div $s7, $a0
              mfhi $a0
              bne $a0, $zero, ShiftCars1
              jal ShiftR
ShiftCars1:   addi $t9, $zero, 256
              addi $s1, $zero, 0
              la $s3, vehicle1
              addi $a0, $zero, 15 # set up different speed
              div $s7, $a0
              mfhi $a0
              bne $a0, $zero, ShiftCars2
              jal ShiftL
ShiftCars2:   addi $t9, $zero, 256
              addi $s1, $zero, 0
              la $s3, vehicle2
              addi $a0, $zero, 40 # set up different speed
              div $s7, $a0
              mfhi $a0
              bne $a0, $zero, ShiftCars3
              jal ShiftR
ShiftCars3:   addi $t9, $zero, 256
              addi $s1, $zero, 0
              la $s3, vehicle3
              addi $a0, $zero, 60 # set up different speed
              div $s7, $a0
              mfhi $a0
              bne $a0, $zero, DrawSafeZone
              jal ShiftL              
              j DrawSafeZone
# functions responsible for shifting              
ShiftR:      bge $s1, $t9, GoBack
             lw $s2, 0($s3)
             andi $t7, $s2, 0xffffff80
             addi $t7, $t7, 128
             addi $s2, $s2, 4
             bge $s2, $t7, Reset$s2R
SaveWordR:   sw $s2, 0($s3)
             addi $s3, $s3, 4
             addi $s1, $s1, 4
             j ShiftR     
ShiftL:      bge $s1, $t9, GoBack
             lw $s2, 0($s3)
             andi $t7, $s2, 0xffffff80
             addi $t7, $t7, -4
             addi $s2, $s2, -4
             ble $s2, $t7, Reset$s2L                 
SaveWordL:   sw $s2, 0($s3)
             addi $s3, $s3, 4
             addi $s1, $s1, 4
             j ShiftL
Reset$s2R:   addi $s2, $s2, -128
             j SaveWordR    
Reset$s2L:   addi $s2, $s2, 128
             j SaveWordL      
              
#Obstacle Drawer              
CarDrawer: lw $s1, 0($t2) # distance between two objects is 48
           sw $s0, 0($s1)
           lw $s1, 4($t2)
           sw $s0, 0($s1)
           lw $s1, 8($t2)
           sw $s0, 0($s1)
           lw $s1, 12($t2)
           sw $s0, 0($s1)
           lw $s1, 16($t2)
           sw $s0, 0($s1)
           lw $s1, 20($t2)
           sw $s0, 0($s1)
           lw $s1, 48($t2)
           sw $s0, 0($s1)
           lw $s1, 52($t2)
           sw $s0, 0($s1)
           lw $s1, 56($t2)
           sw $s0, 0($s1)
           lw $s1, 60($t2)
           sw $s0, 0($s1)
           lw $s1, 64($t2)
           sw $s0, 0($s1)
           lw $s1, 68($t2)
           sw $s0, 0($s1)
           lw $s1, 128($t2)
           sw $s0, 0($s1)
           lw $s1, 132($t2)
           sw $s0, 0($s1)
           lw $s1, 136($t2)
           sw $s0, 0($s1)
           lw $s1, 140($t2)
           sw $s0, 0($s1)
           lw $s1, 144($t2)
           sw $s0, 0($s1)
           lw $s1, 148($t2)
           sw $s0, 0($s1)
           lw $s1, 176($t2)
           sw $s0, 0($s1)
           lw $s1, 180($t2)
           sw $s0, 0($s1)
           lw $s1, 184($t2)
           sw $s0, 0($s1)
           lw $s1, 188($t2)
           sw $s0, 0($s1)
           lw $s1, 192($t2)
           sw $s0, 0($s1)
           lw $s1, 196($t2)
           sw $s0, 0($s1)
           lw $s1, 256($t2)
           sw $s0, 0($s1)
           lw $s1, 260($t2)
           sw $s0, 0($s1)
           lw $s1, 264($t2)
           sw $s0, 0($s1)
           lw $s1, 268($t2)
           sw $s0, 0($s1)
           lw $s1, 272($t2)
           sw $s0, 0($s1)
           lw $s1, 276($t2)
           sw $s0, 0($s1)
           lw $s1, 304($t2)
           sw $s0, 0($s1)
           lw $s1, 308($t2)
           sw $s0, 0($s1)
           lw $s1, 312($t2)
           sw $s0, 0($s1)
           lw $s1, 316($t2)
           sw $s0, 0($s1)
           lw $s1, 320($t2)
           sw $s0, 0($s1)
           lw $s1, 324($t2)
           sw $s0, 0($s1)
           lw $s1, 384($t2)
           sw $s0, 0($s1)
           lw $s1, 388($t2)
           sw $s0, 0($s1)
           lw $s1, 392($t2)
           sw $s0, 0($s1)
           lw $s1, 396($t2)
           sw $s0, 0($s1)
           lw $s1, 400($t2)
           sw $s0, 0($s1)
           lw $s1, 404($t2)
           sw $s0, 0($s1)
           lw $s1, 432($t2)
           sw $s0, 0($s1)
           lw $s1, 436($t2)
           sw $s0, 0($s1)
           lw $s1, 440($t2)
           sw $s0, 0($s1)
           lw $s1, 444($t2)
           sw $s0, 0($s1)
           lw $s1, 448($t2)
           sw $s0, 0($s1)
           lw $s1, 452($t2)
           sw $s0, 0($s1)
           lw $s1, 512($t2)
           sw $s0, 0($s1)
           lw $s1, 516($t2)
           sw $s0, 0($s1)
           lw $s1, 520($t2)
           sw $s0, 0($s1)
           lw $s1, 524($t2)
           sw $s0, 0($s1)
           lw $s1, 528($t2)
           sw $s0, 0($s1)
           lw $s1, 532($t2)
           sw $s0, 0($s1)
           lw $s1, 640($t2)
           sw $s0, 0($s1)
           lw $s1, 644($t2)
           sw $s0, 0($s1)
           lw $s1, 648($t2)
           sw $s0, 0($s1)
           lw $s1, 652($t2)
           sw $s0, 0($s1)
           lw $s1, 656($t2)
           sw $s0, 0($s1)
           lw $s1, 660($t2)
           sw $s0, 0($s1)
           lw $s1, 560($t2)
           sw $s0, 0($s1)
           lw $s1, 564($t2)
           sw $s0, 0($s1)
           lw $s1, 568($t2)
           sw $s0, 0($s1)
           lw $s1, 572($t2)
           sw $s0, 0($s1)
           lw $s1, 576($t2)
           sw $s0, 0($s1)
           lw $s1, 580($t2)
           sw $s0, 0($s1)
           lw $s1, 688($t2)
           sw $s0, 0($s1)
           lw $s1, 692($t2)
           sw $s0, 0($s1)
           lw $s1, 696($t2)
           sw $s0, 0($s1)
           lw $s1, 700($t2)
           sw $s0, 0($s1)
           lw $s1, 704($t2)
           sw $s0, 0($s1)
           lw $s1, 708($t2)
           sw $s0, 0($s1)
           j GoBack             
LogDrawer: lw $s1, 0($t2) # distance between two objects is 48
           sw $s0, 0($s1)
           lw $s1, 4($t2)
           sw $s0, 0($s1)
           lw $s1, 8($t2)
           sw $s0, 0($s1)
           lw $s1, 12($t2)
           sw $s0, 0($s1)
           lw $s1, 16($t2)
           sw $s0, 0($s1)
           lw $s1, 20($t2)
           sw $s0, 0($s1)
           lw $s1, 48($t2)
           sw $s0, 0($s1)
           lw $s1, 52($t2)
           sw $s0, 0($s1)
           lw $s1, 56($t2)
           sw $s0, 0($s1)
           lw $s1, 60($t2)
           sw $s0, 0($s1)
           lw $s1, 64($t2)
           sw $s0, 0($s1)
           lw $s1, 68($t2)
           sw $s0, 0($s1)
           lw $s1, 128($t2)
           sw $s0, 0($s1)
           lw $s1, 132($t2)
           sw $s0, 0($s1)
           lw $s1, 136($t2)
           sw $s0, 0($s1)
           lw $s1, 140($t2)
           sw $s0, 0($s1)
           lw $s1, 144($t2)
           sw $s0, 0($s1)
           lw $s1, 148($t2)
           sw $s0, 0($s1)
           lw $s1, 176($t2)
           sw $s0, 0($s1)
           lw $s1, 180($t2)
           sw $s0, 0($s1)
           lw $s1, 184($t2)
           sw $s0, 0($s1)
           lw $s1, 188($t2)
           sw $s0, 0($s1)
           lw $s1, 192($t2)
           sw $s0, 0($s1)
           lw $s1, 196($t2)
           sw $s0, 0($s1)
           lw $s1, 256($t2)
           sw $s0, 0($s1)
           lw $s1, 260($t2)
           sw $s0, 0($s1)
           lw $s1, 264($t2)
           sw $s0, 0($s1)
           lw $s1, 268($t2)
           sw $s0, 0($s1)
           lw $s1, 272($t2)
           sw $s0, 0($s1)
           lw $s1, 276($t2)
           sw $s0, 0($s1)
           lw $s1, 304($t2)
           sw $s0, 0($s1)
           lw $s1, 308($t2)
           sw $s0, 0($s1)
           lw $s1, 312($t2)
           sw $s0, 0($s1)
           lw $s1, 316($t2)
           sw $s0, 0($s1)
           lw $s1, 320($t2)
           sw $s0, 0($s1)
           lw $s1, 324($t2)
           sw $s0, 0($s1)
           lw $s1, 384($t2)
           sw $s0, 0($s1)
           lw $s1, 388($t2)
           sw $s0, 0($s1)
           lw $s1, 392($t2)
           sw $s0, 0($s1)
           lw $s1, 396($t2)
           sw $s0, 0($s1)
           lw $s1, 400($t2)
           sw $s0, 0($s1)
           lw $s1, 404($t2)
           sw $s0, 0($s1)
           lw $s1, 432($t2)
           sw $s0, 0($s1)
           lw $s1, 436($t2)
           sw $s0, 0($s1)
           lw $s1, 440($t2)
           sw $s0, 0($s1)
           lw $s1, 444($t2)
           sw $s0, 0($s1)
           lw $s1, 448($t2)
           sw $s0, 0($s1)
           lw $s1, 452($t2)
           sw $s0, 0($s1)
           lw $s1, 512($t2)
           sw $s0, 0($s1)
           lw $s1, 516($t2)
           sw $s0, 0($s1)
           lw $s1, 520($t2)
           sw $s0, 0($s1)
           lw $s1, 524($t2)
           sw $s0, 0($s1)
           lw $s1, 528($t2)
           sw $s0, 0($s1)
           lw $s1, 532($t2)
           sw $s0, 0($s1)
           lw $s1, 640($t2)
           sw $s0, 0($s1)
           lw $s1, 644($t2)
           sw $s0, 0($s1)
           lw $s1, 648($t2)
           sw $s0, 0($s1)
           lw $s1, 652($t2)
           sw $s0, 0($s1)
           lw $s1, 656($t2)
           sw $s0, 0($s1)
           lw $s1, 660($t2)
           sw $s0, 0($s1)
           lw $s1, 560($t2)
           sw $s0, 0($s1)
           lw $s1, 564($t2)
           sw $s0, 0($s1)
           lw $s1, 568($t2)
           sw $s0, 0($s1)
           lw $s1, 572($t2)
           sw $s0, 0($s1)
           lw $s1, 576($t2)
           sw $s0, 0($s1)
           lw $s1, 580($t2)
           sw $s0, 0($s1)
           lw $s1, 688($t2)
           sw $s0, 0($s1)
           lw $s1, 692($t2)
           sw $s0, 0($s1)
           lw $s1, 696($t2)
           sw $s0, 0($s1)
           lw $s1, 700($t2)
           sw $s0, 0($s1)
           lw $s1, 704($t2)
           sw $s0, 0($s1)
           lw $s1, 708($t2)
           sw $s0, 0($s1)
           lw $s1, 768($t2)
           sw $s0, 0($s1)
           lw $s1, 772($t2)
           sw $s0, 0($s1)
           lw $s1, 776($t2)
           sw $s0, 0($s1)
           lw $s1, 780($t2)
           sw $s0, 0($s1)
           lw $s1, 784($t2)
           sw $s0, 0($s1)
           lw $s1, 788($t2)
           sw $s0, 0($s1)
           lw $s1, 896($t2)
           sw $s0, 0($s1)
           lw $s1, 900($t2)
           sw $s0, 0($s1)
           lw $s1, 904($t2)
           sw $s0, 0($s1)
           lw $s1, 908($t2)
           sw $s0, 0($s1)
           lw $s1, 912($t2)
           sw $s0, 0($s1)
           lw $s1, 916($t2)
           sw $s0, 0($s1)
           lw $s1,816($t2)
           sw $s0, 0($s1)
           lw $s1, 820($t2)
           sw $s0, 0($s1)
           lw $s1, 824($t2)
           sw $s0, 0($s1)
           lw $s1, 828($t2)
           sw $s0, 0($s1)
           lw $s1, 832($t2)
           sw $s0, 0($s1)
           lw $s1, 836($t2)
           sw $s0, 0($s1)
           lw $s1, 944($t2)
           sw $s0, 0($s1)
           lw $s1, 948($t2)
           sw $s0, 0($s1)
           lw $s1, 952($t2)
           sw $s0, 0($s1)
           lw $s1, 956($t2)
           sw $s0, 0($s1)
           lw $s1, 960($t2)
           sw $s0, 0($s1)
           lw $s1, 964($t2)
           sw $s0, 0($s1)
           
           j GoBack
                            
                                          
# sound effects    
MovingSound:  li $v0, 33
              li $a0, 56
              li $a1, 100
              li $a2, 0
              li $a3, 1000
              syscall
              li $v0, 31
              li $a0, 64
              li $a1, 100
              li $a2, 0
              li $a3, 1000
              syscall
              jr $ra
                                                                               
              
CollideSound: li $v0, 31
              li $a0, 69
              li $a1, 1000
              li $a2, 7
              li $a3, 100
              syscall
              li $v0, 31
              li $a0, 69
              li $a1, 2000
              li $a2, 0
              li $a3, 100
              syscall
              jr $ra
              
GoalSound:    li $v0, 31
              li $a0, 66
              li $a1, 100
              li $a2, 96
              li $a3, 100
              syscall
              li $v0, 31
              li $a0, 69
              li $a1, 100
              li $a2, 96
              li $a3, 100
              syscall
              li $v0, 31
              li $a0, 62
              li $a1, 100
              li $a2, 96
              li $a3, 100
              syscall
              jr $ra
         
GameEndSound: li $v0, 33
              li $a0, 72
              li $a1, 500
              li $a2, 0
              li $a3, 100
              syscall
              li $v0, 33
              li $a0, 71
              li $a1, 1000
              li $a2, 0
              li $a3, 100
              syscall
              li $v0, 33
              li $a0, 72
              li $a1, 500
              li $a2, 0
              li $a3, 100
              syscall
              li $v0, 33
              li $a0, 75
              li $a1, 1000
              li $a2, 0
              li $a3, 100
              syscall
              li $v0, 33
              li $a0, 72
              li $a1, 500
              li $a2, 0
              li $a3, 100
              syscall
              li $v0, 33
              li $a0, 71
              li $a1, 1000
              li $a2, 0
              li $a3, 100
              syscall
              li $v0, 33
              li $a0, 72
              li $a1, 500
              li $a2, 0
              li $a3, 100
              syscall
              li $v0, 33
              li $a0, 71
              li $a1, 1000
              li $a2, 0
              li $a3, 100
              syscall
              li $v0, 33
              li $a0, 72
              li $a1, 500
              li $a2, 0
              li $a3, 100
              syscall
              li $v0, 33
              li $a0, 75
              li $a1, 1000
              li $a2, 0
              li $a3, 100
              syscall
              li $v0, 33
              li $a0, 72
              li $a1, 500
              li $a2, 0
              li $a3, 100
              syscall
              li $v0, 33
              li $a0, 71
              li $a1, 1000
              li $a2, 0
              li $a3, 100
              syscall
              jr $ra



Exit:
li $v0, 10 # terminate the program gracefully
syscall
