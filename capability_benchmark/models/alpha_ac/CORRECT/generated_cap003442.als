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

pred cap003442 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchB)) }
pred cap003442c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchB) and renamed->renamed in capBenchR and (inv2 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003442 { cap003442 iff cap003442c }
check CapBenchEquivalent_cap003442 for 4
