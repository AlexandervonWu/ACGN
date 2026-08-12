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

pred cap003445 { all x: CapBenchA | (x->x in capBenchR and (inv6 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchA and some capBenchS) and some CapBenchB)) }
pred cap003445c { all renamed: CapBenchA | (((no CapBenchA and some capBenchS) and some CapBenchB) and renamed->renamed in capBenchR and (inv6 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003445 { cap003445 iff cap003445c }
check CapBenchEquivalent_cap003445 for 4
