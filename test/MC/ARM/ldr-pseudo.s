@ This test has a partner (ldr-pseudo-darwin.s) that contains matching
@ tests for the ldr-pseudo on darwin targets. We need separate files
@ because the syntax for switching sections and temporary labels differs
@ between darwin and linux. Any tests added here should have a matching
@ test added there.

@RUN: llvm-mc -triple   armv7-unknown-linux-gnueabi %s | FileCheck %s
@RUN: llvm-mc -triple thumbv5-unknown-linux-gnueabi %s | FileCheck %s
@RUN: llvm-mc -triple thumbv7-unknown-linux-gnueabi %s | FileCheck %s

@
@ Check that large constants are converted to ldr from constant pool
@
@ simple test
.section b,"ax",%progbits
@ CHECK-LABEL: f3:
f3:
  ldr r0, =0x10001
@ CHECK: ldr r0, .Ltmp0

@ loading multiple constants
.section c,"ax",%progbits
@ CHECK-LABEL: f4:
f4:
  ldr r0, =0x10002
@ CHECK: ldr r0, .Ltmp1
  adds r0, r0, #1
  adds r0, r0, #1
  adds r0, r0, #1
  adds r0, r0, #1
  ldr r0, =0x10003
@ CHECK: ldr r0, .Ltmp2
  adds r0, r0, #1
  adds r0, r0, #1

@ TODO: the same constants should have the same constant pool location
.section d,"ax",%progbits
@ CHECK-LABEL: f5:
f5:
  ldr r0, =0x10004
@ CHECK: ldr r0, .Ltmp3
  adds r0, r0, #1
  adds r0, r0, #1
  adds r0, r0, #1
  adds r0, r0, #1
  adds r0, r0, #1
  adds r0, r0, #1
  adds r0, r0, #1
  ldr r0, =0x10004
@ CHECK: ldr r0, .Ltmp4
  adds r0, r0, #1
  adds r0, r0, #1
  adds r0, r0, #1
  adds r0, r0, #1
  adds r0, r0, #1
  adds r0, r0, #1

@ a section defined in multiple pieces should be merged and use a single constant pool
.section e,"ax",%progbits
@ CHECK-LABEL: f6:
f6:
  ldr r0, =0x10006
@ CHECK: ldr r0, .Ltmp5
  adds r0, r0, #1
  adds r0, r0, #1
  adds r0, r0, #1

.section f, "ax", %progbits
@ CHECK-LABEL: f7:
f7:
  adds r0, r0, #1
  adds r0, r0, #1
  adds r0, r0, #1

.section e, "ax", %progbits
@ CHECK-LABEL: f8:
f8:
  adds r0, r0, #1
  ldr r0, =0x10007
@ CHECK: ldr r0, .Ltmp6
  adds r0, r0, #1
  adds r0, r0, #1

@
@ Check that symbols can be loaded using ldr pseudo
@

@ load an undefined symbol
.section g,"ax",%progbits
@ CHECK-LABEL: f9:
f9:
  ldr r0, =foo
@ CHECK: ldr r0, .Ltmp7

@ load a symbol from another section
.section h,"ax",%progbits
@ CHECK-LABEL: f10:
f10:
  ldr r0, =f5
@ CHECK: ldr r0, .Ltmp8

@ load a symbol from the same section
.section i,"ax",%progbits
@ CHECK-LABEL: f11:
f11:
  ldr r0, =f12
@ CHECK: ldr r0, .Ltmp9

@ CHECK-LABEL: f12:
f12:
  adds r0, r0, #1
  adds r0, r0, #1

.section j,"ax",%progbits
@ mix of symbols and constants
@ CHECK-LABEL: f13:
f13:
  adds r0, r0, #1
  adds r0, r0, #1
  ldr r0, =0x101
@ CHECK: ldr r0, .Ltmp10
  adds r0, r0, #1
  adds r0, r0, #1
  ldr r0, =bar
@ CHECK: ldr r0, .Ltmp11
  adds r0, r0, #1
  adds r0, r0, #1
@
@ Check for correct usage in other contexts
@

@ usage in macro
.macro useit_in_a_macro
  ldr r0, =0x10008
  ldr r0, =baz
.endm
.section k,"ax",%progbits
@ CHECK-LABEL: f14:
f14:
  useit_in_a_macro
@ CHECK: ldr r0, .Ltmp12
@ CHECK: ldr r0, .Ltmp13

@ usage with expressions
.section l, "ax", %progbits
@ CHECK-LABEL: f15:
f15:
  ldr r0, =0x10001+8
@ CHECK: ldr r0, .Ltmp14
  adds r0, r0, #1
  ldr r0, =bar+4
@ CHECK: ldr r0, .Ltmp15
  adds r0, r0, #1

@
@ Constant Pools
@
@ CHECK: .section b,"ax",%progbits
@ CHECK: .align 2
@ CHECK-LABEL: .Ltmp0:
@ CHECK: .long 65537

@ CHECK: .section c,"ax",%progbits
@ CHECK: .align 2
@ CHECK-LABEL: .Ltmp1:
@ CHECK: .long 65538
@ CHECK-LABEL: .Ltmp2:
@ CHECK: .long 65539

@ CHECK: .section d,"ax",%progbits
@ CHECK: .align 2
@ CHECK-LABEL: .Ltmp3:
@ CHECK: .long 65540
@ CHECK-LABEL: .Ltmp4:
@ CHECK: .long 65540

@ CHECK: .section e,"ax",%progbits
@ CHECK: .align 2
@ CHECK-LABEL: .Ltmp5:
@ CHECK: .long 65542
@ CHECK-LABEL: .Ltmp6:
@ CHECK: .long 65543

@ Should not switch to section because it has no constant pool
@ CHECK-NOT: .section f,"ax",%progbits

@ CHECK: .section g,"ax",%progbits
@ CHECK: .align 2
@ CHECK-LABEL: .Ltmp7:
@ CHECK: .long foo

@ CHECK: .section h,"ax",%progbits
@ CHECK: .align 2
@ CHECK-LABEL: .Ltmp8:
@ CHECK: .long f5

@ CHECK: .section i,"ax",%progbits
@ CHECK: .align 2
@ CHECK-LABEL: .Ltmp9:
@ CHECK: .long f12

@ CHECK: .section j,"ax",%progbits
@ CHECK: .align 2
@ CHECK-LABEL: .Ltmp10:
@ CHECK: .long 257
@ CHECK-LABEL: .Ltmp11:
@ CHECK: .long bar

@ CHECK: .section k,"ax",%progbits
@ CHECK: .align 2
@ CHECK-LABEL: .Ltmp12:
@ CHECK: .long 65544
@ CHECK-LABEL: .Ltmp13:
@ CHECK: .long baz

@ CHECK: .section l,"ax",%progbits
@ CHECK: .align 2
@ CHECK-LABEL: .Ltmp14:
@ CHECK: .long 65545
@ CHECK-LABEL: .Ltmp15:
@ CHECK: .long bar+4
