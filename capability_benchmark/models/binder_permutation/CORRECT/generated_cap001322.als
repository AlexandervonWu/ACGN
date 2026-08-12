sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv2 {
all s : Signal | one signals.s
}

pred inv2c {
	all s : Signal | one signals.s
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001322 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((no CapBenchA and some CapBenchA) and some capBenchS))) }
pred cap001322c { all a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((no CapBenchA and some CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap001322 { cap001322 iff cap001322c }
check CapBenchEquivalent_cap001322 for 4
