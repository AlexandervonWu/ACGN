sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv6 {
all t:Entry|some s:Speed| t->s in signals
}

pred inv6c {
	all t : Entry | some t.signals & Speed
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003972 { all x, y: CapBenchA | (x->y in capBenchR and (inv6 and ((some CapBenchA and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap003972c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv6 and ((some CapBenchA and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003972 { cap003972 iff cap003972c }
check CapBenchEquivalent_cap003972 for 4
