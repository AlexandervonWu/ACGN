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

pred cap004717 { not ((inv3 and ((some CapBenchB or no CapBenchB) or no CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004717c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv3 and ((some CapBenchB or no CapBenchB) or no CapBenchB)))) }
assert CapBenchEquivalent_cap004717 { cap004717 iff cap004717c }
check CapBenchEquivalent_cap004717 for 4
