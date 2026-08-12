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

pred cap003105 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some CapBenchB or some capBenchS) or some CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchR)) }
pred cap003105c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchR) and renamed->renamed in capBenchR and (inv2 and ((some CapBenchB or some capBenchS) or some CapBenchB))) }
assert CapBenchEquivalent_cap003105 { cap003105 iff cap003105c }
check CapBenchEquivalent_cap003105 for 4
