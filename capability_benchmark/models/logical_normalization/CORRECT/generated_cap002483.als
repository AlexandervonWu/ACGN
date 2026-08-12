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

pred cap002483 { ((inv1 and ((no CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB)) iff ((some CapBenchA and no CapBenchA) or no CapBenchA)) }
pred cap002483c { (((not (inv1 and ((no CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB))) or ((some CapBenchA and no CapBenchA) or no CapBenchA)) and ((not ((some CapBenchA and no CapBenchA) or no CapBenchA)) or (inv1 and ((no CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap002483 { cap002483 iff cap002483c }
check CapBenchEquivalent_cap002483 for 4
