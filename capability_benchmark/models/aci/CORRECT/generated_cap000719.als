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

pred cap000719 { (inv2 and ((no CapBenchB or no CapBenchB) and no CapBenchB)) }
pred cap000719c { ((inv2 and ((no CapBenchB or no CapBenchB) and no CapBenchB)) or (inv2 and ((no CapBenchB or no CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap000719 { cap000719 iff cap000719c }
check CapBenchEquivalent_cap000719 for 4
