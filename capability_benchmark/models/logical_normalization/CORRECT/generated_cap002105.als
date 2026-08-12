sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv2 {
all s : Signal | one signals.s
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

pred cap002105 { ((inv2 and ((some CapBenchB or some capBenchS) or some CapBenchB)) iff ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchR)) }
pred cap002105c { (((not (inv2 and ((some CapBenchB or some capBenchS) or some CapBenchB))) or ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchR)) and ((not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchR)) or (inv2 and ((some CapBenchB or some capBenchS) or some CapBenchB)))) }
assert CapBenchEquivalent_cap002105 { cap002105 iff cap002105c }
check CapBenchEquivalent_cap002105 for 4
