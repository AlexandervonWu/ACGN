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

pred cap005001 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv6 and ((some CapBenchB or some CapBenchA) or some CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchA))) }
pred cap005001c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchA)) or (not (inv6 and ((some CapBenchB or some CapBenchA) or some CapBenchA)))) }
assert CapBenchEquivalent_cap005001 { cap005001 iff cap005001c }
check CapBenchEquivalent_cap005001 for 4
