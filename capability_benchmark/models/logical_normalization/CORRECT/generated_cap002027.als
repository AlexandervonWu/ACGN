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

pred cap002027 { ((inv2 and ((no CapBenchB or no CapBenchB) and some CapBenchA)) iff ((some CapBenchA and some CapBenchB) or no CapBenchB)) }
pred cap002027c { (((not (inv2 and ((no CapBenchB or no CapBenchB) and some CapBenchA))) or ((some CapBenchA and some CapBenchB) or no CapBenchB)) and ((not ((some CapBenchA and some CapBenchB) or no CapBenchB)) or (inv2 and ((no CapBenchB or no CapBenchB) and some CapBenchA)))) }
assert CapBenchEquivalent_cap002027 { cap002027 iff cap002027c }
check CapBenchEquivalent_cap002027 for 4
