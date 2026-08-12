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

pred cap001617 { ((all x: CapBenchA | x->x in capBenchR) or (inv2 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB))) }
pred cap001617c { (all x: CapBenchA | (x->x in capBenchR or (inv2 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)))) }
assert CapBenchEquivalent_cap001617 { cap001617 iff cap001617c }
check CapBenchEquivalent_cap001617 for 4
