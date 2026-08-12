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

pred cap003509 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((some CapBenchB or some CapBenchB) or some CapBenchA))) }
pred cap003509c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv2 and ((some CapBenchB or some CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap003509 { cap003509 iff cap003509c }
check CapBenchEquivalent_cap003509 for 4
