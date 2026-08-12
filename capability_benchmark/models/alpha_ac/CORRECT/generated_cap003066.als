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

pred cap003066 { all x: CapBenchA | (x->x in capBenchR and (inv6 and ((no CapBenchA and some CapBenchA) and some CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchB)) }
pred cap003066c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchB) and renamed->renamed in capBenchR and (inv6 and ((no CapBenchA and some CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap003066 { cap003066 iff cap003066c }
check CapBenchEquivalent_cap003066 for 4
