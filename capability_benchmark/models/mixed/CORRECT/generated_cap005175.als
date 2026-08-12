sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv4 {
all t:Track | t in Entry <=> t not in Track.^succs
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

pred cap005175 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchA)) and ((some capBenchR and no CapBenchB) or some capBenchS))) }
pred cap005175c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and no CapBenchB) or some capBenchS)) or (not (inv4 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchA)))) }
assert CapBenchEquivalent_cap005175 { cap005175 iff cap005175c }
check CapBenchEquivalent_cap005175 for 4
