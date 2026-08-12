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

pred cap001329 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv2 and ((some CapBenchB or some CapBenchB) or some capBenchS))) }
pred cap001329c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv2 and ((some CapBenchB or some CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap001329 { cap001329 iff cap001329c }
check CapBenchEquivalent_cap001329 for 4
