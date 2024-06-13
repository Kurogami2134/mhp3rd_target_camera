.psp

monster_pointer equ 0x09DA9860
player_area equ 0x8B24979

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

.createfile "CAMERA.bin", 0x8800000
	// constants
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
	
	lih			t7, @selected_monster  ; load selected monster
	
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
	sih			zero, @selected_monster
@not_zero:

	jal			@monster_in_area  ; check if selected monster is in the area
	nop
	
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
	
	lv.s		s002, 0x00(a3)  ; loads 2/pi
	vdiv.s		s003, s003, s002
	vsgn.s		s001, s001
	vmul.s		s003, s003, s001
	
	; angle is ready in radians
	lv.s		s002, 0x04(a3)  ; loads pi
	vadd.s		s003, s003, s002
	
	lv.s		s002, 0x0C(a3)  ; loads 0
	vsge.s		s000, s001, s002
	
	lv.s		s002, 0x04(a3)  ; loads pi
	vmul.s		s002, s000, s002
	vadd.s		s003, s003, s002
	
	lv.s		s002, 0x08(a3)  ; loads mariana's constant
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
	lv.q		c000, 0x8(sp)
	jr			ra
	addiu		sp, sp, 0x18
@selected_monster:
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

.warning @selected_monster