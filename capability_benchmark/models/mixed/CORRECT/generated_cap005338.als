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
workers in Workstation one -> some Worker

all ws : Workstation | some ws.workers
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

pred cap005338 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((no CapBenchA and no CapBenchA) and some capBenchS)) and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap005338c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv2 and ((no CapBenchA and no CapBenchA) and some capBenchS)))) }
assert CapBenchEquivalent_cap005338 { cap005338 iff cap005338c }
check CapBenchEquivalent_cap005338 for 4
