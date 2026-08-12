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

pred cap003493 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchS or some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) and ((no CapBenchA and no CapBenchB) and no CapBenchA)) }
pred cap003493c { all renamed: CapBenchA | (((no CapBenchA and no CapBenchB) and no CapBenchA) and renamed->renamed in capBenchR and (inv4 and ((some capBenchS or some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003493 { cap003493 iff cap003493c }
check CapBenchEquivalent_cap003493 for 4
