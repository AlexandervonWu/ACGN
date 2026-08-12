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

pred cap005492 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv6 and ((some capBenchR and some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchB or no CapBenchB) or no CapBenchA))) }
pred cap005492c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or no CapBenchB) or no CapBenchA)) or (not (inv6 and ((some capBenchR and some capBenchS) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap005492 { cap005492 iff cap005492c }
check CapBenchEquivalent_cap005492 for 4
