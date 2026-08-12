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

pred cap001785 { ((all x: CapBenchA | x->x in capBenchR) or (inv6 and ((some capBenchS or no CapBenchB) or some capBenchR))) }
pred cap001785c { (all x: CapBenchA | (x->x in capBenchR or (inv6 and ((some capBenchS or no CapBenchB) or some capBenchR)))) }
assert CapBenchEquivalent_cap001785 { cap001785 iff cap001785c }
check CapBenchEquivalent_cap001785 for 4
