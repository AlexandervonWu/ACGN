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

pred cap001016 { all x, y: CapBenchA | (x->y in capBenchR and (inv6 and ((some CapBenchA and no CapBenchA) or some CapBenchA))) }
pred cap001016c { all a, b: CapBenchA | (b->a in capBenchR and (inv6 and ((some CapBenchA and no CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap001016 { cap001016 iff cap001016c }
check CapBenchEquivalent_cap001016 for 4
