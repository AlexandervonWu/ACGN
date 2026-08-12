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

pred cap004857 { not ((inv13 and ((some capBenchS or some capBenchR) or some capBenchS)) and ((no CapBenchA and no CapBenchA) and some CapBenchA)) }
pred cap004857c { ((not ((no CapBenchA and no CapBenchA) and some CapBenchA)) or (not (inv13 and ((some capBenchS or some capBenchR) or some capBenchS)))) }
assert CapBenchEquivalent_cap004857 { cap004857 iff cap004857c }
check CapBenchEquivalent_cap004857 for 4
