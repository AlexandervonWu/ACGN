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

pred cap005462 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchB))) }
pred cap005462c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchB)) or (not (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap005462 { cap005462 iff cap005462c }
check CapBenchEquivalent_cap005462 for 4
