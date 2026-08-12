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

pred cap000541 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv2 and ((some CapBenchB or some capBenchS) or some CapBenchA))) }
pred cap000541c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv2 and ((some CapBenchB or some capBenchS) or some CapBenchA))) }
assert CapBenchEquivalent_cap000541 { cap000541 iff cap000541c }
check CapBenchEquivalent_cap000541 for 4
