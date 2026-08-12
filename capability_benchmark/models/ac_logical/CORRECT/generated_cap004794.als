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

pred cap004794 { not ((inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchR)) and ((no CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap004794c { ((not ((no CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchR)))) }
assert CapBenchEquivalent_cap004794 { cap004794 iff cap004794c }
check CapBenchEquivalent_cap004794 for 4
