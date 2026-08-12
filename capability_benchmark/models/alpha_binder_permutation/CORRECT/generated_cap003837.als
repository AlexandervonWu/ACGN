sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv6 {
all e : Entry | some e.signals & Speed
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

pred cap003837 { all x, y: CapBenchA | (x->y in capBenchR and (inv6 and ((some CapBenchB or no CapBenchA) or some capBenchS))) }
pred cap003837c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv6 and ((some CapBenchB or no CapBenchA) or some capBenchS))) }
assert CapBenchEquivalent_cap003837 { cap003837 iff cap003837c }
check CapBenchEquivalent_cap003837 for 4
