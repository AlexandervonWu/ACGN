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

pred cap002345 { ((inv6 and ((some CapBenchB or no CapBenchB) or some capBenchS)) iff ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchA)) }
pred cap002345c { (((not (inv6 and ((some CapBenchB or no CapBenchB) or some capBenchS))) or ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchA)) and ((not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchA)) or (inv6 and ((some CapBenchB or no CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap002345 { cap002345 iff cap002345c }
check CapBenchEquivalent_cap002345 for 4
