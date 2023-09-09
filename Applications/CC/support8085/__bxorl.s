;
;		Long xor, values are on stack and in hireg:h
;
		.export __xorl
		.setcpu	8085
		.code

__xorl:
	ldsi	2		; base of value to xor
	xchg			; so m is the memory pointer, de the value
	mov	a,m
	xra	e
	mov	e,a
	inx	h
	mov	a,m
	xra	d
	mov	d,a
	inx	h
	push	d
	xchg
	lhld	__hireg
	xchg
	mov	a,m
	xra	e
	mov	e,a
	inx	h
	mov	a,m
	xra	d
	mov	d,a
	xchg
	shld	__hireg
	pop	d		; result
	pop	h
	shld	__retaddr
	pop	h
	pop	h
	xchg
	jmp	__ret
