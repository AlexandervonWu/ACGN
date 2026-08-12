sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv1 {
some Entry and some Exit
}

pred inv1c {
	some Entry
	some Exit
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002297 { ((inv1 and ((some CapBenchB or some capBenchS) or some capBenchR)) iff ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap002297c { (((not (inv1 and ((some CapBenchB or some capBenchS) or some capBenchR))) or ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) and ((not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) or (inv1 and ((some CapBenchB or some capBenchS) or some capBenchR)))) }
assert CapBenchEquivalent_cap002297 { cap002297 iff cap002297c }
check CapBenchEquivalent_cap002297 for 4
