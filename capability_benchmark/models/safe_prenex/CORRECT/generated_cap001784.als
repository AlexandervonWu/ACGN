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

pred cap001784 { ((some x: CapBenchA | x->x in capBenchR) and (inv2 and ((some capBenchR and no CapBenchB) or some capBenchR))) }
pred cap001784c { (some x: CapBenchA | (x->x in capBenchR and (inv2 and ((some capBenchR and no CapBenchB) or some capBenchR)))) }
assert CapBenchEquivalent_cap001784 { cap001784 iff cap001784c }
check CapBenchEquivalent_cap001784 for 4
