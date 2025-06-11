global strlen_avx512
section .text

strlen_avx512:
    mov     rax, rdi               ; rax = start pointer (save original pointer)

.loop:
    vmovdqu8 zmm0, [rdi]           ; Load 64 bytes unaligned into zmm0
    vpxord    zmm1, zmm1, zmm1     ; zmm1 = 0s (cleared)
    vpcmpeqb  k1, zmm0, zmm1       ; Compare zmm0 to 0s, result in k1 mask register
    kmovq     rcx, k1              ; Copy mask register k1 to rcx (64-bit)

    test     rcx, rcx              ; Is any byte == 0?
    jnz      .found                ; Yes → jump to calculate length

    add      rdi, 64               ; Advance pointer by 64 bytes
    jmp      .loop                 ; Repeat

.found:
    tzcnt    rcx, rcx              ; Find index of first null byte in the 64 bytes
    add      rdi, rcx              ; Add offset to original pointer
    sub      rdi, rax              ; Subtract base address → string length
    mov      rax, rdi              ; Return length in rax
    ret
