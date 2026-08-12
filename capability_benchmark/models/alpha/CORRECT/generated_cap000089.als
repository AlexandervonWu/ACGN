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

pred cap000089 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv2 and ((some CapBenchB or no CapBenchB) or some CapBenchB))) }
pred cap000089c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv2 and ((some CapBenchB or no CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap000089 { cap000089 iff cap000089c }
check CapBenchEquivalent_cap000089 for 4
