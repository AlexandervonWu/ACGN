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

pred cap003427 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((no CapBenchB or some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchA and no CapBenchB) or some CapBenchB)) }
pred cap003427c { all renamed: CapBenchA | (((some CapBenchA and no CapBenchB) or some CapBenchB) and renamed->renamed in capBenchR and (inv2 and ((no CapBenchB or some capBenchS) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003427 { cap003427 iff cap003427c }
check CapBenchEquivalent_cap003427 for 4
