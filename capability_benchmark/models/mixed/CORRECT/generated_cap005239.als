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

pred cap005239 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv6 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchB)) and ((some capBenchR and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005239c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv6 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchB)))) }
assert CapBenchEquivalent_cap005239 { cap005239 iff cap005239c }
check CapBenchEquivalent_cap005239 for 4
