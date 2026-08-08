module alloy4fun_augmented_trainStationOld_inv11
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

pred inv11_oracle[] {
all t : Train | always (some t.pos implies once some t.pos & Entry)
}

pred inv11_correct_0[] {
always ( all t:Train | some t.pos implies once some t.pos :> Entry)
}

pred inv11_correct_1[] {
always ( all t:Train| some t.pos implies  once ( some t.pos and t.pos in Entry) )
}

