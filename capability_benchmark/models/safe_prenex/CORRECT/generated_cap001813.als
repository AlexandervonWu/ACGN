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

pred cap001813 { ((all x: CapBenchA | x->x in capBenchR) or (inv2 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
pred cap001813c { (all x: CapBenchA | (x->x in capBenchR or (inv2 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchR)))) }
assert CapBenchEquivalent_cap001813 { cap001813 iff cap001813c }
check CapBenchEquivalent_cap001813 for 4
