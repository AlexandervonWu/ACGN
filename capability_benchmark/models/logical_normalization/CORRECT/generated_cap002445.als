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

pred cap002445 { not ((inv13 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchA and some capBenchS) and some CapBenchB)) }
pred cap002445c { ((not (inv13 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) or (not ((no CapBenchA and some capBenchS) and some CapBenchB))) }
assert CapBenchEquivalent_cap002445 { cap002445 iff cap002445c }
check CapBenchEquivalent_cap002445 for 4
