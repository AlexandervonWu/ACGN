sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv2 {
all signal: Signal | one track:Track | signal in track.signals
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

pred cap000536 { ((inv2 and ((some capBenchR and some capBenchR) or some CapBenchA)) and ((some CapBenchB or no CapBenchA) or no CapBenchB) and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS)) }
pred cap000536c { (((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS) and (inv2 and ((some capBenchR and some capBenchR) or some CapBenchA)) and ((some CapBenchB or no CapBenchA) or no CapBenchB)) }
assert CapBenchEquivalent_cap000536 { cap000536 iff cap000536c }
check CapBenchEquivalent_cap000536 for 4
