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

pred cap002829 { not (((inv6 and ((some CapBenchB or some CapBenchB) or some capBenchS))) since (((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap002829c { ((not (inv6 and ((some CapBenchB or some CapBenchB) or some capBenchS))) triggered (not ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002829 { cap002829 iff cap002829c }
check CapBenchEquivalent_cap002829 for 4
