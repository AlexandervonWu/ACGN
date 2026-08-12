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

pred cap001202 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((no CapBenchA and some CapBenchB) and no CapBenchB))) }
pred cap001202c { all a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((no CapBenchA and some CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap001202 { cap001202 iff cap001202c }
check CapBenchEquivalent_cap001202 for 4
