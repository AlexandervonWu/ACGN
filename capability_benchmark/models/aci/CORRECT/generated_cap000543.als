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

pred cap000543 { ((inv2 and ((no CapBenchB or some capBenchS) and some CapBenchA)) or ((some CapBenchA and no CapBenchB) or no CapBenchB) or ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap000543c { (((some CapBenchA and no CapBenchB) or no CapBenchB) or ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) or (inv2 and ((no CapBenchB or some capBenchS) and some CapBenchA))) }
assert CapBenchEquivalent_cap000543 { cap000543 iff cap000543c }
check CapBenchEquivalent_cap000543 for 4
