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

pred cap000614 { ((inv2 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchR) and ((some capBenchS or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap000614c { (((some capBenchS or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB) and (inv2 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchR)) }
assert CapBenchEquivalent_cap000614 { cap000614 iff cap000614c }
check CapBenchEquivalent_cap000614 for 4
