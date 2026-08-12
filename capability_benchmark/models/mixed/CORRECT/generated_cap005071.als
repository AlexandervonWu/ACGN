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

pred cap005071 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchB)) and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB))) }
pred cap005071c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) or (not (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchB)))) }
assert CapBenchEquivalent_cap005071 { cap005071 iff cap005071c }
check CapBenchEquivalent_cap005071 for 4
