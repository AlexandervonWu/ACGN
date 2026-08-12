sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv2 {
all s: Signal | one t: Track | s in t.signals
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

pred cap003352 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some CapBenchA and some capBenchR) or some capBenchS)) and ((some capBenchS or some CapBenchB) or some CapBenchA)) }
pred cap003352c { all renamed: CapBenchA | (((some capBenchS or some CapBenchB) or some CapBenchA) and renamed->renamed in capBenchR and (inv2 and ((some CapBenchA and some capBenchR) or some capBenchS))) }
assert CapBenchEquivalent_cap003352 { cap003352 iff cap003352c }
check CapBenchEquivalent_cap003352 for 4
