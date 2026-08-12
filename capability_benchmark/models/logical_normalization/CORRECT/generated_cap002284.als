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

pred cap002284 { ((inv6 and ((some capBenchR and no CapBenchB) or some capBenchR)) implies ((some CapBenchB or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap002284c { ((not (inv6 and ((some capBenchR and no CapBenchB) or some capBenchR))) or ((some CapBenchB or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
assert CapBenchEquivalent_cap002284 { cap002284 iff cap002284c }
check CapBenchEquivalent_cap002284 for 4
