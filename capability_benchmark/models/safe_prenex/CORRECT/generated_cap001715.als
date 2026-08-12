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

pred cap001715 { ((all x: CapBenchA | x->x in capBenchR) or (inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchB))) }
pred cap001715c { (all x: CapBenchA | (x->x in capBenchR or (inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchB)))) }
assert CapBenchEquivalent_cap001715 { cap001715 iff cap001715c }
check CapBenchEquivalent_cap001715 for 4
