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

pred cap003702 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((no CapBenchA and some CapBenchB) and no CapBenchB))) }
pred cap003702c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv2 and ((no CapBenchA and some CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap003702 { cap003702 iff cap003702c }
check CapBenchEquivalent_cap003702 for 4
