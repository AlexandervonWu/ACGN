sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv1 {
some e:Entry,ex:Exit | e in Track and ex in Track
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

pred cap003659 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchA))) }
pred cap003659c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap003659 { cap003659 iff cap003659c }
check CapBenchEquivalent_cap003659 for 4
