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

pred cap000283 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv2 and ((no CapBenchB or no CapBenchB) and some capBenchR))) }
pred cap000283c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv2 and ((no CapBenchB or no CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap000283 { cap000283 iff cap000283c }
check CapBenchEquivalent_cap000283 for 4
