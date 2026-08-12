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

pred cap003201 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some CapBenchB or some CapBenchB) or no CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS)) }
pred cap003201c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS) and renamed->renamed in capBenchR and (inv2 and ((some CapBenchB or some CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap003201 { cap003201 iff cap003201c }
check CapBenchEquivalent_cap003201 for 4
