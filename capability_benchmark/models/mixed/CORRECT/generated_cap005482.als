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

pred cap005482 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((no CapBenchA and some capBenchR) and CapBenchA in CapBenchA + CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchA))) }
pred cap005482c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchA)) or (not (inv1 and ((no CapBenchA and some capBenchR) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap005482 { cap005482 iff cap005482c }
check CapBenchEquivalent_cap005482 for 4
