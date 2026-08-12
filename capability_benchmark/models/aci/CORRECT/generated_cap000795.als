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

pred cap000795 { ((inv6 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchR)) or ((some capBenchR and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB) or ((no CapBenchA and some CapBenchA) and no CapBenchA)) }
pred cap000795c { (((some capBenchR and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB) or ((no CapBenchA and some CapBenchA) and no CapBenchA) or (inv6 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchR))) }
assert CapBenchEquivalent_cap000795 { cap000795 iff cap000795c }
check CapBenchEquivalent_cap000795 for 4
