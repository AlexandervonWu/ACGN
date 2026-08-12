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

pred cap005315 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) and ((some CapBenchA and some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap005315c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv2 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR)))) }
assert CapBenchEquivalent_cap005315 { cap005315 iff cap005315c }
check CapBenchEquivalent_cap005315 for 4
