sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv6 {
all t:Entry|some s:Speed| t->s in signals
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

pred cap000258 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv6 and ((no CapBenchA and some CapBenchA) and some capBenchR))) }
pred cap000258c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv6 and ((no CapBenchA and some CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap000258 { cap000258 iff cap000258c }
check CapBenchEquivalent_cap000258 for 4
