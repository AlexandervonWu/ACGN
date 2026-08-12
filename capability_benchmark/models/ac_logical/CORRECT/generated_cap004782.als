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

pred cap004782 { not ((inv6 and ((no CapBenchA and no CapBenchB) and some capBenchR)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap004782c { ((not ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv6 and ((no CapBenchA and no CapBenchB) and some capBenchR)))) }
assert CapBenchEquivalent_cap004782 { cap004782 iff cap004782c }
check CapBenchEquivalent_cap004782 for 4
