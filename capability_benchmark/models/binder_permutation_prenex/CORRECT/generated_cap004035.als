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

pred cap004035 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv6 and ((no CapBenchB or some capBenchR) and some CapBenchA))) }
pred cap004035c { some a, b: CapBenchA | (b->a in capBenchR and (inv6 and ((no CapBenchB or some capBenchR) and some CapBenchA))) }
assert CapBenchEquivalent_cap004035 { cap004035 iff cap004035c }
check CapBenchEquivalent_cap004035 for 4
