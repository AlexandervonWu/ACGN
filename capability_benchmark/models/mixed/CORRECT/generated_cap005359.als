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

pred cap005359 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchS)) and ((some capBenchR and no CapBenchA) or some CapBenchA))) }
pred cap005359c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and no CapBenchA) or some CapBenchA)) or (not (inv4 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchS)))) }
assert CapBenchEquivalent_cap005359 { cap005359 iff cap005359c }
check CapBenchEquivalent_cap005359 for 4
