module alloy4fun_augmented_trainStationOld_inv1
prox : set Track,
	signal : lone Signal
}
sig Junction extends Track {}
sig Entry, Exit in Track {}

sig Signal {}
var sig Green in Signal {}

sig Train {
	var pos : lone Track
}

fact Layout {
	all t : Track | t not in Junction iff (lone t.prox and lone prox.t)
	no t : Track | t in t.^prox
	all s : Signal | one signal.s
	all j : Junction, t : prox.j | some t.signal
	all t : Track | t in Entry iff no prox.t
	all t : Track | t in Exit iff no t.prox
}

pred inv1_oracle[] {
no Green
}

pred inv1_correct_0[] {
all s : Signal | s not in Green
}

pred inv1_correct_1[] {
no Signal & Green
}

pred inv1_correct_2[] {
(some s:Signal | s in Green) since (historically (all s:Signal | s not in Green))
}

pred inv1_correct_3[] {
historically no Green
}

pred inv1_correct_4[] {
all s: Signal | no Green
}

pred inv1_correct_5[] {
no s:Green|   s  in Signal
}

