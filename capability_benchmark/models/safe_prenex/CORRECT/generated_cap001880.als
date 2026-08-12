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

pred cap001880 { ((some x: CapBenchA | x->x in capBenchR) and (inv6 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
pred cap001880c { (some x: CapBenchA | (x->x in capBenchR and (inv6 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap001880 { cap001880 iff cap001880c }
check CapBenchEquivalent_cap001880 for 4
