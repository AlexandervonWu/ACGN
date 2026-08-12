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

pred cap002364 { not (all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some capBenchR and some capBenchS) or some capBenchS)))) }
pred cap002364c { some x: CapBenchA | not (x->x in capBenchR and (inv2 and ((some capBenchR and some capBenchS) or some capBenchS))) }
assert CapBenchEquivalent_cap002364 { cap002364 iff cap002364c }
check CapBenchEquivalent_cap002364 for 4
