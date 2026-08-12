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

pred cap002736 { not historically ((inv2 and ((some capBenchR and some capBenchS) or no CapBenchB))) }
pred cap002736c { once (not (inv2 and ((some capBenchR and some capBenchS) or no CapBenchB))) }
assert CapBenchEquivalent_cap002736 { cap002736 iff cap002736c }
check CapBenchEquivalent_cap002736 for 4
