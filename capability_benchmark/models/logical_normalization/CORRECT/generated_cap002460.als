sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv2 {
all x: Signal | one y : Track | x in y.signals
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

pred cap002460 { not (all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some capBenchR and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)))) }
pred cap002460c { some x: CapBenchA | not (x->x in capBenchR and (inv2 and ((some capBenchR and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002460 { cap002460 iff cap002460c }
check CapBenchEquivalent_cap002460 for 4
