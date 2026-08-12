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

pred cap005173 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((some capBenchS or some capBenchS) or no CapBenchA)) and ((no CapBenchA and no CapBenchB) and some capBenchS))) }
pred cap005173c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and no CapBenchB) and some capBenchS)) or (not (inv1 and ((some capBenchS or some capBenchS) or no CapBenchA)))) }
assert CapBenchEquivalent_cap005173 { cap005173 iff cap005173c }
check CapBenchEquivalent_cap005173 for 4
