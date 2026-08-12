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

pred cap004261 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv2 and ((some capBenchS or some CapBenchA) or some capBenchR))) }
pred cap004261c { some a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some capBenchS or some CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap004261 { cap004261 iff cap004261c }
check CapBenchEquivalent_cap004261 for 4
