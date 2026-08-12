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

pred cap004557 { not ((inv3 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchB)) }
pred cap004557c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchB)) or (not (inv3 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)))) }
assert CapBenchEquivalent_cap004557 { cap004557 iff cap004557c }
check CapBenchEquivalent_cap004557 for 4
