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
all w : Workstation | some w.workers
all w : Worker | one workers.w
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

pred cap004692 { not ((inv2 and ((some CapBenchA and some CapBenchA) or no CapBenchB)) and ((some capBenchS or some capBenchS) or some capBenchS)) }
pred cap004692c { ((not ((some capBenchS or some capBenchS) or some capBenchS)) or (not (inv2 and ((some CapBenchA and some CapBenchA) or no CapBenchB)))) }
assert CapBenchEquivalent_cap004692 { cap004692 iff cap004692c }
check CapBenchEquivalent_cap004692 for 4
