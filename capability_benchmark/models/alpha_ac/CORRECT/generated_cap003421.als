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

pred cap003421 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some capBenchS or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchA and no CapBenchA) and some CapBenchB)) }
pred cap003421c { all renamed: CapBenchA | (((no CapBenchA and no CapBenchA) and some CapBenchB) and renamed->renamed in capBenchR and (inv2 and ((some capBenchS or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003421 { cap003421 iff cap003421c }
check CapBenchEquivalent_cap003421 for 4
