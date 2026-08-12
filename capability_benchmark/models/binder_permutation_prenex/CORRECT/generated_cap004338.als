sig Track {
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
pred inv3 {
all t : Train | always t.pos' = t.pos
}

pred inv3c { 
	always pos' = pos
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004338 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv3 and ((no CapBenchA and no CapBenchA) and some capBenchS))) }
pred cap004338c { some a, b: CapBenchA | (b->a in capBenchR and (inv3 and ((no CapBenchA and no CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap004338 { cap004338 iff cap004338c }
check CapBenchEquivalent_cap004338 for 4
