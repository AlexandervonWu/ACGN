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

pred cap005076 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((some capBenchR and some CapBenchB) or some CapBenchB)) and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB))) }
pred cap005076c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) or (not (inv2 and ((some capBenchR and some CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap005076 { cap005076 iff cap005076c }
check CapBenchEquivalent_cap005076 for 4
