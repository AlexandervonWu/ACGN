sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv6 {
all t:Entry|some s:Speed| t->s in signals
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

pred cap000379 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv6 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS))) }
pred cap000379c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv6 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap000379 { cap000379 iff cap000379c }
check CapBenchEquivalent_cap000379 for 4
