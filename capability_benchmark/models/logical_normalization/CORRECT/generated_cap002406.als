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

pred cap002406 { not (all x: CapBenchA | (x->x in capBenchR and (inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))))) }
pred cap002406c { some x: CapBenchA | not (x->x in capBenchR and (inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002406 { cap002406 iff cap002406c }
check CapBenchEquivalent_cap002406 for 4
