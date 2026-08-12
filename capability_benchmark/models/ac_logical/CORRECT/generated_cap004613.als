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

pred cap004613 { not ((inv6 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchR)) }
pred cap004613c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchR)) or (not (inv6 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)))) }
assert CapBenchEquivalent_cap004613 { cap004613 iff cap004613c }
check CapBenchEquivalent_cap004613 for 4
