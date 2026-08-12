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

pred cap001490 { all x, y: CapBenchA | (x->y in capBenchR and (inv6 and ((no CapBenchA and some capBenchS) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap001490c { all a, b: CapBenchA | (b->a in capBenchR and (inv6 and ((no CapBenchA and some capBenchS) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap001490 { cap001490 iff cap001490c }
check CapBenchEquivalent_cap001490 for 4
