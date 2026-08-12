sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv4 {
all e : Track | e in Entry iff (all t : Track | t not in succs.e)
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

pred cap003738 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchB))) }
pred cap003738c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchB))) }
assert CapBenchEquivalent_cap003738 { cap003738 iff cap003738c }
check CapBenchEquivalent_cap003738 for 4
