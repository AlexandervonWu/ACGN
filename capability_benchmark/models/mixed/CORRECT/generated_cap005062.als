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

pred cap005062 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some CapBenchA)) and ((no CapBenchB or some capBenchS) and no CapBenchB))) }
pred cap005062c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or some capBenchS) and no CapBenchB)) or (not (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some CapBenchA)))) }
assert CapBenchEquivalent_cap005062 { cap005062 iff cap005062c }
check CapBenchEquivalent_cap005062 for 4
