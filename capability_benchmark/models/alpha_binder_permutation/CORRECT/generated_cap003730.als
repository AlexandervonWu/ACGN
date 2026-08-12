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

pred cap003730 { all x, y: CapBenchA | (x->y in capBenchR and (inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchB))) }
pred cap003730c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchB))) }
assert CapBenchEquivalent_cap003730 { cap003730 iff cap003730c }
check CapBenchEquivalent_cap003730 for 4
