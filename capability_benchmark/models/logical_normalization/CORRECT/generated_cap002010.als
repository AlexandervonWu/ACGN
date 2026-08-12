sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv2 {
all s : Signal | one signals.s
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

pred cap002010 { not (all x: CapBenchA | (x->x in capBenchR and (inv2 and ((no CapBenchA and some CapBenchB) and some CapBenchA)))) }
pred cap002010c { some x: CapBenchA | not (x->x in capBenchR and (inv2 and ((no CapBenchA and some CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap002010 { cap002010 iff cap002010c }
check CapBenchEquivalent_cap002010 for 4
