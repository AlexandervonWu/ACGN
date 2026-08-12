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

pred cap005119 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB)) and ((some capBenchR and some capBenchR) or some capBenchR))) }
pred cap005119c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and some capBenchR) or some capBenchR)) or (not (inv2 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB)))) }
assert CapBenchEquivalent_cap005119 { cap005119 iff cap005119c }
check CapBenchEquivalent_cap005119 for 4
