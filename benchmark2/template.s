	.file	"template.c"
	.option nopic
	.text
	.globl	__floatsisf
	.globl	__mulsf3
	.globl	__fixsfsi
	.globl	__divsf3
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	addi	s0,sp,48
	li	a5,134217728
	sw	a5,-28(s0)
	lw	a5,-28(s0)
	sw	zero,0(a5)
	sw	zero,-20(s0)
	j	.L2
.L3:
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L2:
	lw	a4,-20(s0)
	li	a5,401408
	addi	a5,a5,-1409
	ble	a4,a5,.L3
	lw	a5,-28(s0)
	li	a4,255
	sw	a4,0(a5)
	sw	zero,-24(s0)
	j	.L4
.L5:
	li	a5,1062
	sw	a5,-32(s0)
	lui	a5,%hi(.LC0)
	lw	a5,%lo(.LC0)(a5)
	sw	a5,-36(s0)
	lw	a0,-32(s0)
	call	__floatsisf
	mv	a5,a0
	lw	a1,-36(s0)
	mv	a0,a5
	call	__mulsf3
	mv	a5,a0
	mv	a0,a5
	call	__fixsfsi
	mv	a5,a0
	sw	a5,-40(s0)
	lw	a0,-40(s0)
	call	__floatsisf
	mv	a5,a0
	mv	a1,a5
	lw	a0,-36(s0)
	call	__mulsf3
	mv	a5,a0
	sw	a5,-44(s0)
	lw	a0,-32(s0)
	call	__floatsisf
	mv	a5,a0
	lw	a1,-36(s0)
	mv	a0,a5
	call	__divsf3
	mv	a5,a0
	sw	a5,-44(s0)
	lui	a5,%hi(.LC1)
	lw	a1,%lo(.LC1)(a5)
	lw	a0,-44(s0)
	call	__mulsf3
	mv	a5,a0
	sw	a5,-44(s0)
	lw	a5,-24(s0)
	addi	a5,a5,1
	sw	a5,-24(s0)
.L4:
	lw	a4,-24(s0)
	li	a5,98304
	addi	a5,a5,1695
	ble	a4,a5,.L5
	lw	a5,-28(s0)
	sw	zero,0(a5)
	li	a5,0
	mv	a0,a5
	lw	ra,44(sp)
	lw	s0,40(sp)
	addi	sp,sp,48
	jr	ra
	.size	main, .-main
	.section	.rodata
	.align	2
.LC0:
	.word	1160105984
	.align	2
.LC1:
	.word	1094713344
	.ident	"GCC: (GNU) 8.2.0"
