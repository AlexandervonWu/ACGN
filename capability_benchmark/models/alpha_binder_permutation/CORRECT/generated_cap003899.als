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
pred inv13 {
always all t : Train | (one t.pos and no t.pos') implies (always no t.pos')
}

pred inv13c {
	all t : Train | always ((no t.pos and once some t.pos) implies always no t.pos)
}

check correct { inv13 <=> inv13c}
pred under { inv13 and !inv13c}
pred over { !inv13 and inv13c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003899 { all x, y: CapBenchA | (x->y in capBenchR and (inv13 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap003899c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv13 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003899 { cap003899 iff cap003899c }
check CapBenchEquivalent_cap003899 for 4
