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

pred cap002177 { ((inv2 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) iff ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchS)) }
pred cap002177c { (((not (inv2 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA))) or ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchS)) and ((not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchS)) or (inv2 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)))) }
assert CapBenchEquivalent_cap002177 { cap002177 iff cap002177c }
check CapBenchEquivalent_cap002177 for 4
