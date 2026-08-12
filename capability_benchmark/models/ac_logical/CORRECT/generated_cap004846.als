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

pred cap004846 { not ((inv6 and ((no CapBenchA and no CapBenchB) and some capBenchS)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchA)) }
pred cap004846c { ((not ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchA)) or (not (inv6 and ((no CapBenchA and no CapBenchB) and some capBenchS)))) }
assert CapBenchEquivalent_cap004846 { cap004846 iff cap004846c }
check CapBenchEquivalent_cap004846 for 4
