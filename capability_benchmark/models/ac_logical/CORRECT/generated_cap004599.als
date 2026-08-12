sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv2 {
all x: Signal | one y : Track | x in y.signals
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

pred cap004599 { not ((inv2 and ((no CapBenchB or some capBenchR) and some CapBenchB)) and ((some CapBenchA and no CapBenchA) or some capBenchR)) }
pred cap004599c { ((not ((some CapBenchA and no CapBenchA) or some capBenchR)) or (not (inv2 and ((no CapBenchB or some capBenchR) and some CapBenchB)))) }
assert CapBenchEquivalent_cap004599 { cap004599 iff cap004599c }
check CapBenchEquivalent_cap004599 for 4
