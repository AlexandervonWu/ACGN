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

pred cap004992 { not ((inv6 and ((some capBenchR and some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchB or no CapBenchB) or no CapBenchA)) }
pred cap004992c { ((not ((some CapBenchB or no CapBenchB) or no CapBenchA)) or (not (inv6 and ((some capBenchR and some capBenchS) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004992 { cap004992 iff cap004992c }
check CapBenchEquivalent_cap004992 for 4
