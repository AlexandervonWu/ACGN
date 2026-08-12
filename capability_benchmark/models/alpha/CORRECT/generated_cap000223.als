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

pred cap000223 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchB))) }
pred cap000223c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap000223 { cap000223 iff cap000223c }
check CapBenchEquivalent_cap000223 for 4
