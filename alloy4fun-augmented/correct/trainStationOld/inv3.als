module alloy4fun_augmented_trainStationOld_inv3
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

pred inv3_oracle[] {
always pos' = pos
}

pred inv3_correct_0[] {
all t : Train | always t.pos' = t.pos
}

pred inv3_correct_1[] {
always all t : Train | t.pos = t.pos'
}

pred inv3_correct_2[] {
always pos = pos'
}

pred inv3_correct_3[] {
always (all t:Train | (t.pos)' = t.pos)
}

pred inv3_correct_4[] {
all t: Train, tk: Track | (t->tk in pos implies always t->tk in pos) and (t->tk not in pos implies always t->tk not in pos)
}

pred inv3_correct_5[] {
always all t: Train, tk: Track | (t->tk in pos implies always t->tk in pos) and (t->tk not in pos implies always t->tk not in pos)
}

pred inv3_correct_6[] {
always(all t : Train  | always (t.pos' = t.pos))
}

pred inv3_correct_7[] {
always all t:Train | t.pos' = t.pos
}

pred inv3_correct_8[] {
all t : Train | always t.pos = t.pos'
}

