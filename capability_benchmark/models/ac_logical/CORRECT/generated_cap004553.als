sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv2 {
all s: Signal | one t: Track | s in t.signals
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

pred cap004553 { not ((inv2 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) and ((no CapBenchA and some capBenchR) and no CapBenchB)) }
pred cap004553c { ((not ((no CapBenchA and some capBenchR) and no CapBenchB)) or (not (inv2 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)))) }
assert CapBenchEquivalent_cap004553 { cap004553 iff cap004553c }
check CapBenchEquivalent_cap004553 for 4
