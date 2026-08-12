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

pred cap003653 { all x, y: CapBenchA | (x->y in capBenchR and (inv6 and ((some CapBenchB or no CapBenchB) or no CapBenchA))) }
pred cap003653c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv6 and ((some CapBenchB or no CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap003653 { cap003653 iff cap003653c }
check CapBenchEquivalent_cap003653 for 4
