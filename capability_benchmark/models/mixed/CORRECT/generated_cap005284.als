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

pred cap005284 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((some capBenchR and no CapBenchB) or some capBenchR)) and ((some CapBenchB or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap005284c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv2 and ((some capBenchR and no CapBenchB) or some capBenchR)))) }
assert CapBenchEquivalent_cap005284 { cap005284 iff cap005284c }
check CapBenchEquivalent_cap005284 for 4
