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

pred cap004504 { not ((inv2 and ((some capBenchR and some CapBenchA) or some CapBenchA)) and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) }
pred cap004504c { ((not ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) or (not (inv2 and ((some capBenchR and some CapBenchA) or some CapBenchA)))) }
assert CapBenchEquivalent_cap004504 { cap004504 iff cap004504c }
check CapBenchEquivalent_cap004504 for 4
