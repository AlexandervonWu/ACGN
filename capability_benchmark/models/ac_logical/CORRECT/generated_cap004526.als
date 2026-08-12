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

pred cap004526 { not ((inv2 and ((no CapBenchA and no CapBenchB) and some CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchB)) }
pred cap004526c { ((not ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchB)) or (not (inv2 and ((no CapBenchA and no CapBenchB) and some CapBenchA)))) }
assert CapBenchEquivalent_cap004526 { cap004526 iff cap004526c }
check CapBenchEquivalent_cap004526 for 4
