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

pred cap003103 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchB)) and ((some capBenchR and no CapBenchA) or some capBenchR)) }
pred cap003103c { all renamed: CapBenchA | (((some capBenchR and no CapBenchA) or some capBenchR) and renamed->renamed in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchB))) }
assert CapBenchEquivalent_cap003103 { cap003103 iff cap003103c }
check CapBenchEquivalent_cap003103 for 4
