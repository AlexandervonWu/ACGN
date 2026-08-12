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

pred cap002028 { not (all x: CapBenchA | (x->x in capBenchR and (inv6 and ((some capBenchR and no CapBenchB) or some CapBenchA)))) }
pred cap002028c { some x: CapBenchA | not (x->x in capBenchR and (inv6 and ((some capBenchR and no CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap002028 { cap002028 iff cap002028c }
check CapBenchEquivalent_cap002028 for 4
