sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv2 {
all s: Signal | s in Track.signals
all s: Signal | all t,t1 : Track | s in t.signals and s in t1.signals implies t=t1
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

pred cap003448 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some CapBenchA and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) and ((some capBenchS or some capBenchS) or some CapBenchB)) }
pred cap003448c { all renamed: CapBenchA | (((some capBenchS or some capBenchS) or some CapBenchB) and renamed->renamed in capBenchR and (inv2 and ((some CapBenchA and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003448 { cap003448 iff cap003448c }
check CapBenchEquivalent_cap003448 for 4
