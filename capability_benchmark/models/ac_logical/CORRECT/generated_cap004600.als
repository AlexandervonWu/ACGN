sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv6 {
all e : Entry | some e.signals & Speed
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

pred cap004600 { not ((inv6 and ((some capBenchR and some capBenchR) or some CapBenchB)) and ((some CapBenchB or no CapBenchA) or some capBenchR)) }
pred cap004600c { ((not ((some CapBenchB or no CapBenchA) or some capBenchR)) or (not (inv6 and ((some capBenchR and some capBenchR) or some CapBenchB)))) }
assert CapBenchEquivalent_cap004600 { cap004600 iff cap004600c }
check CapBenchEquivalent_cap004600 for 4
