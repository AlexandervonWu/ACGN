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

pred cap001228 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((some capBenchR and some capBenchR) or no CapBenchB))) }
pred cap001228c { all a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some capBenchR and some capBenchR) or no CapBenchB))) }
assert CapBenchEquivalent_cap001228 { cap001228 iff cap001228c }
check CapBenchEquivalent_cap001228 for 4
