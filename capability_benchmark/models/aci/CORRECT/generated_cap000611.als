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

pred cap000611 { (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchB)) }
pred cap000611c { ((inv2 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchB)) or (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchB))) }
assert CapBenchEquivalent_cap000611 { cap000611 iff cap000611c }
check CapBenchEquivalent_cap000611 for 4
