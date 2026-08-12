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

pred cap002871 { not (((inv2 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS))) since (((some CapBenchA and some capBenchR) or some CapBenchA))) }
pred cap002871c { ((not (inv2 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS))) triggered (not ((some CapBenchA and some capBenchR) or some CapBenchA))) }
assert CapBenchEquivalent_cap002871 { cap002871 iff cap002871c }
check CapBenchEquivalent_cap002871 for 4
