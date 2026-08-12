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

pred cap000625 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv2 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB))) }
pred cap000625c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv2 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap000625 { cap000625 iff cap000625c }
check CapBenchEquivalent_cap000625 for 4
