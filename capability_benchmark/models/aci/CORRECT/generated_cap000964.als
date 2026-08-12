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

pred cap000964 { (inv2 and ((some CapBenchA and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap000964c { ((inv2 and ((some CapBenchA and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) and (inv2 and ((some CapBenchA and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000964 { cap000964 iff cap000964c }
check CapBenchEquivalent_cap000964 for 4
