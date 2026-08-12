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

pred cap003757 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((some CapBenchB or some CapBenchA) or some capBenchR))) }
pred cap003757c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv4 and ((some CapBenchB or some CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap003757 { cap003757 iff cap003757c }
check CapBenchEquivalent_cap003757 for 4
