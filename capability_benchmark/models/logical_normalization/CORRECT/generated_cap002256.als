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

pred cap002256 { not (all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some CapBenchA and some CapBenchA) or some capBenchR)))) }
pred cap002256c { some x: CapBenchA | not (x->x in capBenchR and (inv2 and ((some CapBenchA and some CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap002256 { cap002256 iff cap002256c }
check CapBenchEquivalent_cap002256 for 4
