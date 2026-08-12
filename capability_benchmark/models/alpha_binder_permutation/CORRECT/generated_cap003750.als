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

pred cap003750 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchB))) }
pred cap003750c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap003750 { cap003750 iff cap003750c }
check CapBenchEquivalent_cap003750 for 4
