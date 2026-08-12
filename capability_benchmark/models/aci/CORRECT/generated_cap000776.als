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

pred cap000776 { ((inv2 and ((some capBenchR and no CapBenchA) or some capBenchR)) and ((some CapBenchB or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchB)) }
pred cap000776c { (((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchB) and (inv2 and ((some capBenchR and no CapBenchA) or some capBenchR)) and ((some CapBenchB or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) }
assert CapBenchEquivalent_cap000776 { cap000776 iff cap000776c }
check CapBenchEquivalent_cap000776 for 4
