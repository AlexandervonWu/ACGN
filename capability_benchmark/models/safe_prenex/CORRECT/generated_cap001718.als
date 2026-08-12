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

pred cap001718 { ((some x: CapBenchA | x->x in capBenchR) and (inv6 and ((no CapBenchA and no CapBenchB) and no CapBenchB))) }
pred cap001718c { (some x: CapBenchA | (x->x in capBenchR and (inv6 and ((no CapBenchA and no CapBenchB) and no CapBenchB)))) }
assert CapBenchEquivalent_cap001718 { cap001718 iff cap001718c }
check CapBenchEquivalent_cap001718 for 4
