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

pred cap000607 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv6 and ((no CapBenchB or some capBenchS) and some CapBenchB))) }
pred cap000607c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv6 and ((no CapBenchB or some capBenchS) and some CapBenchB))) }
assert CapBenchEquivalent_cap000607 { cap000607 iff cap000607c }
check CapBenchEquivalent_cap000607 for 4
