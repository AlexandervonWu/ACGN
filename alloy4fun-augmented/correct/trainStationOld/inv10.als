module alloy4fun_augmented_trainStationOld_inv10
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

pred inv10_oracle[] {
all j : Junction | always lone (prox.j).signal & Green
}

pred inv10_correct_0[] {
always (all j:Junction |  lone((prox.j).signal :> Green))
}

pred inv10_correct_1[] {
always (all j:Junction | lone (prox.j).signal & Green)
always (lone (prox.Junction).signal & Green)
}

pred inv10_correct_2[] {
always (all j:Junction | lone (prox.j).signal & Green)
}

pred inv10_correct_3[] {
always (lone (prox.Junction).signal & Green)
}

pred inv10_correct_4[] {
always (all j:Junction | lone (prox.Junction).signal & Green)
}

