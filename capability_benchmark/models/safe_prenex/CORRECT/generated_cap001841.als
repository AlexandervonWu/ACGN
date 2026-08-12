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

pred cap001841 { ((all x: CapBenchA | x->x in capBenchR) or (inv6 and ((some capBenchS or no CapBenchA) or some capBenchS))) }
pred cap001841c { (all x: CapBenchA | (x->x in capBenchR or (inv6 and ((some capBenchS or no CapBenchA) or some capBenchS)))) }
assert CapBenchEquivalent_cap001841 { cap001841 iff cap001841c }
check CapBenchEquivalent_cap001841 for 4
