sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv2 {
all s: Signal | one t: Track | s in t.signals
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

pred cap005372 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) and ((some CapBenchB or some capBenchR) or some CapBenchA))) }
pred cap005372c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or some capBenchR) or some CapBenchA)) or (not (inv2 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)))) }
assert CapBenchEquivalent_cap005372 { cap005372 iff cap005372c }
check CapBenchEquivalent_cap005372 for 4
