module alloy4fun_augmented_trainStationOld_inv2
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

pred inv2_oracle[] {
all s : Signal | eventually s in Green
}

pred inv2_correct_0[] {
eventually (all s:Signal | eventually s in Green)
}

pred inv2_correct_1[] {
all t : Track | eventually t.signal in Green
}

pred inv2_correct_2[] {
all s : Signal - Green | eventually s in Green
}

