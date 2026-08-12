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

pred cap001646 { ((some x: CapBenchA | x->x in capBenchR) and (inv2 and ((no CapBenchA and no CapBenchA) and no CapBenchA))) }
pred cap001646c { (some x: CapBenchA | (x->x in capBenchR and (inv2 and ((no CapBenchA and no CapBenchA) and no CapBenchA)))) }
assert CapBenchEquivalent_cap001646 { cap001646 iff cap001646c }
check CapBenchEquivalent_cap001646 for 4
