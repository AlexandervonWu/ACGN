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

pred cap003285 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some capBenchS or no CapBenchB) or some capBenchR)) and ((no CapBenchA and some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap003285c { all renamed: CapBenchA | (((no CapBenchA and some CapBenchB) and CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv2 and ((some capBenchS or no CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap003285 { cap003285 iff cap003285c }
check CapBenchEquivalent_cap003285 for 4
