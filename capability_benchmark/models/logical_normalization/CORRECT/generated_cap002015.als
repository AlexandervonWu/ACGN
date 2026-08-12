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

pred cap002015 { ((inv2 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchA)) iff ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)) }
pred cap002015c { (((not (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchA))) or ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)) and ((not ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)) or (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchA)))) }
assert CapBenchEquivalent_cap002015 { cap002015 iff cap002015c }
check CapBenchEquivalent_cap002015 for 4
