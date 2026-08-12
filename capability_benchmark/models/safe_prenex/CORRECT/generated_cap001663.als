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

pred cap001663 { ((all x: CapBenchA | x->x in capBenchR) or (inv2 and ((no CapBenchB or some capBenchR) and no CapBenchA))) }
pred cap001663c { (all x: CapBenchA | (x->x in capBenchR or (inv2 and ((no CapBenchB or some capBenchR) and no CapBenchA)))) }
assert CapBenchEquivalent_cap001663 { cap001663 iff cap001663c }
check CapBenchEquivalent_cap001663 for 4
