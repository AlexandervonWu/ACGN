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

pred cap003563 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchA))) }
pred cap003563c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap003563 { cap003563 iff cap003563c }
check CapBenchEquivalent_cap003563 for 4
