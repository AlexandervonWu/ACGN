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

pred cap003208 { all x: CapBenchA | (x->x in capBenchR and (inv6 and ((some CapBenchA and no CapBenchA) or no CapBenchB)) and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) }
pred cap003208c { all renamed: CapBenchA | (((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchS) and renamed->renamed in capBenchR and (inv6 and ((some CapBenchA and no CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap003208 { cap003208 iff cap003208c }
check CapBenchEquivalent_cap003208 for 4
