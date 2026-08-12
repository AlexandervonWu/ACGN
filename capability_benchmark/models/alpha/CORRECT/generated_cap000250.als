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

pred cap000250 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv6 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchB))) }
pred cap000250c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv6 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap000250 { cap000250 iff cap000250c }
check CapBenchEquivalent_cap000250 for 4
