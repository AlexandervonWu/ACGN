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

pred cap004752 { not ((inv6 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) and ((some CapBenchB or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004752c { ((not ((some CapBenchB or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv6 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)))) }
assert CapBenchEquivalent_cap004752 { cap004752 iff cap004752c }
check CapBenchEquivalent_cap004752 for 4
