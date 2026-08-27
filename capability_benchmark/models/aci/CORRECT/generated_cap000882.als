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

pred cap000882 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some capBenchS))) }
pred cap000882c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap000882 { cap000882 iff cap000882c }
check CapBenchEquivalent_cap000882 for 4
