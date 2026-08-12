sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv4 {
all t : Track | t in Entry iff no t.~succs
}

pred inv4c {
	all t : Track | t in Entry iff no succs.t
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002377 { no x: CapBenchA | (x->x in capBenchR and (inv4 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
pred cap002377c { all x: CapBenchA | not (x->x in capBenchR and (inv4 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap002377 { cap002377 iff cap002377c }
check CapBenchEquivalent_cap002377 for 4
