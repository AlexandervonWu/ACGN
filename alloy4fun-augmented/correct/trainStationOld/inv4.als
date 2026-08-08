module alloy4fun_augmented_trainStationOld_inv4
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

pred inv4_oracle[] {
always all t : Track | lone pos.t
}

pred inv4_correct_0[] {
always (pos.(~pos) in iden)
}

pred inv4_correct_1[] {
all t : Track | always lone t.~pos
}

pred inv4_correct_2[] {
always all disj t1,t2:Train | no (t1.pos & t2.pos )
}

pred inv4_correct_3[] {
all disj t1,t2:Train | always no (t1.pos & t2.pos)
}

pred inv4_correct_4[] {
always all disj t, t2 : Train | some (t.pos + t2.pos) => t.pos != t2.pos
}

pred inv4_correct_5[] {
always all disj t, t2 : Train | some (t.pos) => t.pos != t2.pos
}

pred inv4_correct_6[] {
always( all tk : Track | lone pos.tk )
}

pred inv4_correct_7[] {
always all t : Track| lone (t.~pos)
}

