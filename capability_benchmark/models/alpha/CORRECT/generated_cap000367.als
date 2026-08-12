sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv1 {
some t,a:Track| t in Entry and a in Exit
}

pred inv1c {
	some Entry
	some Exit
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000367 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchS))) }
pred cap000367c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some capBenchS))) }
assert CapBenchEquivalent_cap000367 { cap000367 iff cap000367c }
check CapBenchEquivalent_cap000367 for 4
