module alloy4fun_augmented_trainStationOld_inv15
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

pred inv15_oracle[] {
all t : Train, p : Track | not (eventually always t.pos = p)
}

pred inv15_correct_0[] {
always (all t:pos.Track | eventually (t.pos)' != t.pos)
}

pred inv15_correct_1[] {
always all t : Train | some t.pos implies eventually t.pos != t.pos'
}

pred inv15_correct_2[] {
always eventually (all t:Train | (no t.pos => eventually some t.pos ) and some t.pos => eventually (t.pos !=t.pos')   )
}

