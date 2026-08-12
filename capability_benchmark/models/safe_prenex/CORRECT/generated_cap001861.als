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

pred cap001861 { ((all x: CapBenchA | x->x in capBenchR) or (inv2 and ((some CapBenchB or some capBenchS) or some capBenchS))) }
pred cap001861c { (all x: CapBenchA | (x->x in capBenchR or (inv2 and ((some CapBenchB or some capBenchS) or some capBenchS)))) }
assert CapBenchEquivalent_cap001861 { cap001861 iff cap001861c }
check CapBenchEquivalent_cap001861 for 4
