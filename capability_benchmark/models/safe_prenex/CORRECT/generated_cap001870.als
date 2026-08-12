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

pred cap001870 { ((some x: CapBenchA | x->x in capBenchR) and (inv6 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS))) }
pred cap001870c { (some x: CapBenchA | (x->x in capBenchR and (inv6 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS)))) }
assert CapBenchEquivalent_cap001870 { cap001870 iff cap001870c }
check CapBenchEquivalent_cap001870 for 4
