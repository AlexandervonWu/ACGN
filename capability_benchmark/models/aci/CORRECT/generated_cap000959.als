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

pred cap000959 { (inv6 and ((no CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap000959c { ((inv6 and ((no CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) or (inv6 and ((no CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000959 { cap000959 iff cap000959c }
check CapBenchEquivalent_cap000959 for 4
