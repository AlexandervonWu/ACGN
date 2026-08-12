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

pred cap004170 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv2 and ((no CapBenchA and some capBenchS) and no CapBenchA))) }
pred cap004170c { some a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((no CapBenchA and some capBenchS) and no CapBenchA))) }
assert CapBenchEquivalent_cap004170 { cap004170 iff cap004170c }
check CapBenchEquivalent_cap004170 for 4
