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

pred cap004719 { not ((inv2 and ((no CapBenchB or no CapBenchB) and no CapBenchB)) and ((some CapBenchA and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004719c { ((not ((some CapBenchA and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv2 and ((no CapBenchB or no CapBenchB) and no CapBenchB)))) }
assert CapBenchEquivalent_cap004719 { cap004719 iff cap004719c }
check CapBenchEquivalent_cap004719 for 4
