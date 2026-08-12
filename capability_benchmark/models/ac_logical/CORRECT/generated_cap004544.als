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

pred cap004544 { not ((inv2 and ((some capBenchR and some capBenchS) or some CapBenchA)) and ((some CapBenchB or no CapBenchB) or no CapBenchB)) }
pred cap004544c { ((not ((some CapBenchB or no CapBenchB) or no CapBenchB)) or (not (inv2 and ((some capBenchR and some capBenchS) or some CapBenchA)))) }
assert CapBenchEquivalent_cap004544 { cap004544 iff cap004544c }
check CapBenchEquivalent_cap004544 for 4
