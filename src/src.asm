.psp

monster_pointer equ 0x09DA9860
player_area equ 0x8B24979
sceGeListEnQueue equ 0x08960CF8
ViewMatrix equ 0x09B486B0
crosshair_tex_ptr equ 0x9fff360

icon_x equ 0
icon_y equ 225

.include "./src/gpu_macros.asm"

.macro lih,dest,value
	lui			at, value / 0x10000
	lh			dest, value & 0xFFFF(at)
.endmacro

.macro lib,dest,value
	lui			at, value / 0x10000
	lb			dest, value & 0xFFFF(at)
.endmacro

.macro sih,orig,value
	lui			at, value / 0x10000
	sh			orig, value & 0xFFFF(at)
.endmacro

.createfile "./bin/CAMERA.bin", 0x8800C00

; Constants
.area 0x10, 0x0
pi2:
	.word 0x3f22f983  ; pi/2
pi:
	.word 0x40490fdb  ; pi
magic:
	.word 0x4a22f983  ; mariana
	
	.word 0x0  ; zero
.endarea
	
	addiu		sp, sp, -0x18
	sv.q		c000, 0x8(sp)
	sw			ra, 0x4(sp)
	
	lih			t7, selected_monster  ; load selected monster
	
	addiu		a3, a0, 0x80  ; a0 contains pointer to player data
	
	; load player coordinates
	lv.s		s000, 0x0(a3)
	lv.s		s001, 0x8(a3)
	
	li			a3, monster_pointer
	add			t7, a3, t7
	
	lw			t7, 0x0(t7)
	
	bne			zero, t7, @not_zero
	nop
	lw			t7, 0x0(a3)
	sih			zero, selected_monster
@not_zero:

	jal			@monster_in_area  ; check if selected monster is in the area
	nop

    li	        a3,0x40
	lui	        t6,0x880
	sh	        a3,0x17D8(t6)
	
	; lood monster coordinates
	lv.s		s002, 0x80(t7)
	lv.s		s003, 0x88(t7)
	
	; get x and y
	vsub.p		c000, c002, c000
	
	; math be mathing
	vmul.p		c002, c000, c000
	vfad.p		r020, c002  ; r020 = s003
	vsqrt.s		s003, s003
	vdiv.s		s003, s000, s003
	vasin.s		s003, s003
	
	lui			a3, 0x880
	
	lv.s		s002, 0xC00(a3)  ; loads 2/pi
	vdiv.s		s003, s003, s002
	vsgn.s		s001, s001
	vmul.s		s003, s003, s001
	
	; angle is ready in radians
	lv.s		s002, 0xC04(a3)  ; loads pi
	vadd.s		s003, s003, s002
	
	lv.s		s002, 0xC0C(a3)  ; loads 0
	vsge.s		s000, s001, s002
	
	lv.s		s002, 0xC04(a3)  ; loads pi
	vmul.s		s002, s000, s002
	vadd.s		s003, s003, s002
	
	lv.s		s002, 0xC08(a3)  ; loads mariana's constant
	vmul.s		s003, s003, s002
	vf2in.s		s000, s003, 0x0
	
	; value is ready, but needs to be flipped
	
	sv.s		s000, 0x0(sp)
	
	li			t7,0x0
	lwr			t7,0x2(sp)
	sll			t7,t7,0x8
	lwr			t7,0x3(sp)
	lwl			t6,0x2(sp)
	lwl			t6,0x0(sp)
	lui			t5,0xFFFF
	and			t6,t6,t5
	li			t5,0xFFFF
	and			t7,t7,t5
	or			v0,t6,t7

@ret:
	; load old vfpu register and return
	lw			ra, 0x4(sp)
	addiu		ra, ra, 0xC
    nop; for some reason next line's sp turns to t8 if this isn't here
	lv.q		c000, 0x8(sp)
	jr			ra
	addiu		sp, sp, 0x18
selected_monster:
	.word 0xDEADBEEF

@monster_in_area:
	lb			t6, 0xD6(t7)
	
	lib			t5, player_area
	
	beq			t5, t6, @@ret
	nop
	lw			ra, 0x4(sp)
	addiu		ra, ra, 0xC
	j			@ret+0xC
	lw			v0, 0x74(s5)
@@ret:
	jr			ra
	nop

.close

.createfile "./bin/RENDER.bin", 0x08801600
;  ICON RENDERING

.func render
    addiu       sp, sp, -0x4
    sw          ra, 0x00(sp)
    
    jal         set_cursor
    nop

    li          t1, 0x0
    li          t0, 0x0
@loop:
    jal         get_id
    move        a0, t1
    jal         load_texture
    move        a0, v0
    
    addiu       t1, t1, 4
    addiu       t0, t0, 0x10
    slti        at, t0, 0x30
    bne         at, zero, @loop
    nop

    li          a0, gpu_code
    li          a2, 0
    li          a3, 0
    jal         sceGeListEnQueue
    li          a1, 0x0

    b           crosshair_stuff
    
@render_return:

    lw          ra, 0x0(sp)
    addiu       sp, sp, 0x4
    lw          a0, 0x8(sp)
    lw          v0, 0x4(sp)
    j           0x09D63AE4
    nop
    
.endfunc

.func set_cursor

    lih         a0, selected_monster

    slti        at, a0, 9
    bne         at, zero, @continue
    nop
    li          a0, 0
    sih         a0, selected_monster
    
@continue:

    srl         a0, a0, 2
    li          at, select_vertices
    
    sll         a2, a0, 5
    sll         a3, a0, 3
    addu        a2, a2, a3
    sll         a3, a0, 1
    addu        a0, a2, a3

    addiu       a0, a0, icon_x+10
    sh          a0, 0x08(at)
    addiu       a0, a0, 22
    sh          a0, 0x18(at)

    jr          ra
    nop

.endfunc

.func get_id

    li          a1, monster_pointer
    addu        a1, a1, a0
    lw          a0, 0x0(a1)
    beql        a0, zero, get_id_ret
    li          v0, 0x0
    addiu       a0, a0, 0x62
    lb          v0, 0x0(a0)
    slti        at, v0, 65
    beql        at, zero, get_id_ret
    li          v0, 0x0
get_id_ret:
    jr          ra
    nop

.endfunc

.func load_texture
    bne         a0, zero, normal_tex_load
    nop

    li          at, vertices
    addu        at, at, t0
    addu        at, at, t0

    sw          zero, 0x00(at)
    sw          zero, 0x10(at)

    li          at, 0xaed0
    li          a1, clut_add
    addu        a1, a1, t0
    sh          at, 0x0(a1)

    jr          ra
    nop

normal_tex_load:
    ; set CLUT
    addiu       a0, a0, -1

    slti        at, a0, 33
    beql        at, zero, @@skip1
    addiu       a0, a0, -4
@@skip1:

    sll         a1, a0, 6

    slti        at, a0, 23
    beql        at, zero, @@skip
    addiu       a1, -0x40
@@skip:

    li          at, 0xaed0
    add         at, at, a1
    li          a1, clut_add
    addu        a1, a1, t0
    sh          at, 0x0(a1)

    ; set vertices
    li          at, vertices
    addu        at, at, t0
    addu        at, at, t0
    srl         a1, a0, 0x3
    
    ; * 42
    sll         a2, a1, 5
    sll         a3, a1, 3
    addu        a2, a2, a3
    sll         a3, a1, 1
    addu        a1, a2, a3
    
    
    sh          a1, 0x02(at)
    addiu       a1, a1, 42
    sh          a1, 0x12(at)
    
    srl         a1, a0, 0x3
    sll         a1, a1, 0x3
    subu        a1, a0, a1
    
    ; * 42
    sll         a2, a1, 5
    sll         a3, a1, 3
    addu        a2, a2, a3
    sll         a3, a1, 1
    addu        a1, a2, a3
    
    
    sh          a1, 0x00(at)
    addiu       a1, a1, 42
    sh          a1, 0x10(at)

ret:
    jr          ra
    nop
.endfunc

crosshair_timer:
    .word       0xDEADBEEF

crosshair_stuff:
    li          a1, crosshair_timer
    lh          a0, 0x0(a1)
    beq         a0, zero, @render_return
    nop
    addiu       a0, a0, -0x1
    sh          a0, 0x0(a1)

    ; set texture addr
    li          a0, crosshair_tex_ptr
    lw          a0, 0x0(a0)
    sll         a0, a0, 8
    srl         a0, a0, 8
    lui         a1, 0xA000
    or          a1, a0, a1
    li          a2, crosshair_tex_add
    sw          a1, 0x0(a2)

    ; set clut addr
    li          a1, 0x8210
    add         a0, a0, a1
    lui         a1, 0xB000
    or          a1, a0, a1
    li          a2, crosshair_clut_add
    sw          a1, 0x0(a2)

world_to_screen:  ; thanks pggkun
    ; load view matrix
    li      a0, ViewMatrix

    lv.q    r100, 0x00(a0)
    lv.q    r101, 0x10(a0)
    lv.q    r102, 0x20(a0)
    lv.q    r103, 0x30(a0)
    
    li      a0, monster_pointer
    lih     a1, selected_monster
    addu    a0, a0, a1
    lw		a0, 0x0(a0)

    ; skip if monster not in area
    lb			a1, 0xD6(a0)
	lib			a2, player_area
    bne         a2, a1, @render_return
    nop

    ; load monster coords
    lv.q  c500, 0x80(a0)
    vone.s  s503

    ; view matrix * monster coords
    vtfm4.q r600, m100, c500

    ; set projection matrix
    vzero.q  c500
    vzero.q  c510
    vzero.q  c520
    vzero.q  c530

    li	a0,	0x3f9b8c00
    mtv	a0, s500

    li	a0, 0x40093eff
    mtv	a0, s511

    li	a0, 0xbf800000
    mtv	a0, s522

    li	a0, 0xbf800000
    mtv	a0, s532

    li	a0, 0xc2700000
    mtv	a0, s523

    ; projection matrix * view matrix * monster coords
    vtfm4.q r601, M500, r600

    vdiv.s s602, s601, s631
    vdiv.s s612, s611, s631
    vdiv.s s622, s621, s631

    li	a0, 0x43f00000
    mtv	a0, s600

    li	a0, 0x43880000
    mtv	a0, s610

    li	a0, 0x3f000000
    mtv	a0, s620

    vadd.s s602, s602, s630
    vmul.s s602, s602, s620
    vmul.s s602, s602, s600 ;result x

    vsub.s s612, s630, s612
    vmul.s s612, s612, s620
    vmul.s s612, s612, s610 ;result y

    ; set crosshair vertices
    vf2iz.p     r602, r602, 0
    mfv         a1, s602
    mfv         a2, s612
    addiu       a1, a1, -0xC
    addiu       a2, a2, -0x15

    li          a0, crosshair_vertices
    sh          a1, 0x08(a0)
    sh          a2, 0x0A(a0)

    addiu       a1, a1, 25
    addiu       a2, a2, 25
    sh          a1, 0x18(a0)
    sh          a2, 0x1A(a0)


    li          a0, crosshair_gpu
    li          a2, 0
    li          a3, 0
    jal         sceGeListEnQueue
    li          a1, 0x0

    b           @render_return
    nop
.align 0x10

crosshair_gpu:
    offset      0
    base        8
    vtype       1, 2, 7, 0, 2, 0, 0, 0
    tfilter     0, 0
    tmode       1, 0, 0
    tpf         4

crosshair_tex_add:
    tbp0        0x6AA950
    tbw0        0x100, 9
    
    tsize0      8, 8

    clutf       3, 0xff
    clutaddhi   0x09
    
    vaddr       crosshair_vertices-0x08000000
    tme         1
    tfunc       0, 1

crosshair_clut_add:
    clutaddlo     0x6AA950+0x8210
    load_clut   2
    tflush
    prim        2, 6

    finish
    end

.align 0x10

gpu_code:
    offset      0
    base        8
    vtype       1, 2, 7, 0, 2, 0, 0, 0
    tfilter     0, 0
    tmode       1, 0, 0
    tpf         4
    tbp0        0x2cbcc0
    tbw0        0x160, 9
    tsize0      9, 9

    clutf       3, 0xff
    clutaddhi   0x09
    
    vaddr       vertices-0x08000000
    tme         1
    tfunc       0, 1

clut_add:
    clutaddlo     0x2d0000
    load_clut   2
    tflush
    prim        2, 6

    clutaddlo     0x2d0000
    load_clut   2
    tflush
    prim        2, 6

    clutaddlo     0x2d0000
    load_clut   2
    tflush
    prim        2, 6

    ; draw select icon
    tbp0        0x2a0460
    tbw0        256, 9
    tsize0      8, 8
    clutaddlo   0x2a86f0 - (0x40*1)
    load_clut   2
    tflush
    prim        2, 6

    finish
    end

.align 0x10
vertices:
    vertex      42, 0, 0xFFFFFFFF, icon_x, icon_y, 0
    vertex      42+42, 42, 0xFFFFFFFF, icon_x+42, icon_y+42, 0
    vertex      42, 0, 0xFFFFFFFF, icon_x+42, icon_y, 0
    vertex      42+42, 42, 0xFFFFFFFF, icon_x+82, icon_y+42, 0
    vertex      42, 0, 0xFFFFFFFF, icon_x+82, icon_y, 0
    vertex      42+42, 42, 0xFFFFFFFF, icon_x+124, icon_y+42, 0
select_vertices:
    vertex      129, 56, 0xFFFFFFFF, icon_x+10, icon_y+32, 0
    vertex      140, 63, 0xFFFFFFFF, icon_x+10+22, icon_y+32+14, 0
crosshair_vertices:
    vertex      57, 142, 0xFFFFFFFF, 0, 0, 0
    vertex      82, 167, 0xFFFFFFFF, 100, 100, 0
.close

.warning "Selected monster: " + selected_monster
.warning "Render: " + render
