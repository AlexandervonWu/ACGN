sig Workstation {
	workers : set Worker,
	succ : set Workstation
}
one sig begin, end in Workstation {}

sig Worker {}
sig Human, Robot extends Worker {}

abstract sig Product {
	parts : set Product	
}

sig Material extends Product {}

sig Component extends Product {
	workstation : set Workstation
}

sig Dangerous in Product {}
pred inv2 {
all wtt : Workstation | some wtt.workers
all w : Worker | one wtt : Workstation | w in wtt.workers
}

pred inv2c {
	workers in Workstation one -> some Worker
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002649 { not (((inv2 and ((some capBenchS or no CapBenchA) or no CapBenchA))) since (((no CapBenchA and some CapBenchA) and some capBenchS))) }
pred cap002649c { ((not (inv2 and ((some capBenchS or no CapBenchA) or no CapBenchA))) triggered (not ((no CapBenchA and some CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap002649 { cap002649 iff cap002649c }
check CapBenchEquivalent_cap002649 for 4
