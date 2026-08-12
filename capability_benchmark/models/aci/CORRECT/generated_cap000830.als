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

pred cap000830 { ((inv2 and ((no CapBenchA and some CapBenchB) and some capBenchS)) and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB) and ((some capBenchS or some capBenchR) or no CapBenchA)) }
pred cap000830c { (((some capBenchS or some capBenchR) or no CapBenchA) and (inv2 and ((no CapBenchA and some CapBenchB) and some capBenchS)) and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB)) }
assert CapBenchEquivalent_cap000830 { cap000830 iff cap000830c }
check CapBenchEquivalent_cap000830 for 4
