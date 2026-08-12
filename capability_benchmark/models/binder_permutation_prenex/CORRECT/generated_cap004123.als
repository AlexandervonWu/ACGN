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

pred cap004123 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv2 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchB))) }
pred cap004123c { some a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap004123 { cap004123 iff cap004123c }
check CapBenchEquivalent_cap004123 for 4
