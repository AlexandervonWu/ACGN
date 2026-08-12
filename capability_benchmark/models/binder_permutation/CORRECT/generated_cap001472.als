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

pred cap001472 { all x, y: CapBenchA | (x->y in capBenchR and (inv6 and ((some CapBenchA and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap001472c { all a, b: CapBenchA | (b->a in capBenchR and (inv6 and ((some CapBenchA and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap001472 { cap001472 iff cap001472c }
check CapBenchEquivalent_cap001472 for 4
