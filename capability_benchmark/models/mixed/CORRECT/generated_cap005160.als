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

pred cap005160 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((some CapBenchA and some capBenchR) or no CapBenchA)) and ((some capBenchS or some CapBenchB) or some capBenchS))) }
pred cap005160c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or some CapBenchB) or some capBenchS)) or (not (inv1 and ((some CapBenchA and some capBenchR) or no CapBenchA)))) }
assert CapBenchEquivalent_cap005160 { cap005160 iff cap005160c }
check CapBenchEquivalent_cap005160 for 4
