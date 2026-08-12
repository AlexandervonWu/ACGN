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
(all ws: Workstation | some ws.workers) and (all w: Worker | one workers.w)
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

pred cap002983 { not once ((inv2 and ((no CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap002983c { historically (not (inv2 and ((no CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002983 { cap002983 iff cap002983c }
check CapBenchEquivalent_cap002983 for 4
