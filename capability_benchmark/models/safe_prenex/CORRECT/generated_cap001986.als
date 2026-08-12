sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv1 {
some Entry and some Exit
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

pred cap001986 { ((some x: CapBenchA | x->x in capBenchR) and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap001986c { (some x: CapBenchA | (x->x in capBenchR and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap001986 { cap001986 iff cap001986c }
check CapBenchEquivalent_cap001986 for 4
