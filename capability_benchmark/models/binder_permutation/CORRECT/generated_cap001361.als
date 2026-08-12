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

pred cap001361 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv6 and ((some CapBenchB or some capBenchS) or some capBenchS))) }
pred cap001361c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv6 and ((some CapBenchB or some capBenchS) or some capBenchS))) }
assert CapBenchEquivalent_cap001361 { cap001361 iff cap001361c }
check CapBenchEquivalent_cap001361 for 4
