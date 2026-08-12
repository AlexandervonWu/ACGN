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

pred cap003054 { all x: CapBenchA | (x->x in capBenchR and (inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)) and ((no CapBenchB or some capBenchR) and no CapBenchB)) }
pred cap003054c { all renamed: CapBenchA | (((no CapBenchB or some capBenchR) and no CapBenchB) and renamed->renamed in capBenchR and (inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA))) }
assert CapBenchEquivalent_cap003054 { cap003054 iff cap003054c }
check CapBenchEquivalent_cap003054 for 4
