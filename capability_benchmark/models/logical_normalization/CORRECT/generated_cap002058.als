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

pred cap002058 { not (all x: CapBenchA | (x->x in capBenchR and (inv6 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchA)))) }
pred cap002058c { some x: CapBenchA | not (x->x in capBenchR and (inv6 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap002058 { cap002058 iff cap002058c }
check CapBenchEquivalent_cap002058 for 4
