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

pred cap004307 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv3 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR))) }
pred cap004307c { some a, b: CapBenchA | (b->a in capBenchR and (inv3 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR))) }
assert CapBenchEquivalent_cap004307 { cap004307 iff cap004307c }
check CapBenchEquivalent_cap004307 for 4
