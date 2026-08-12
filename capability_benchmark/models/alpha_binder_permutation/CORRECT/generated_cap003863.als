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

pred cap003863 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((no CapBenchB or some capBenchS) and some capBenchS))) }
pred cap003863c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((no CapBenchB or some capBenchS) and some capBenchS))) }
assert CapBenchEquivalent_cap003863 { cap003863 iff cap003863c }
check CapBenchEquivalent_cap003863 for 4
