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

pred cap003084 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some capBenchR and no CapBenchA) or some CapBenchB)) and ((some CapBenchB or some CapBenchA) or some capBenchR)) }
pred cap003084c { all renamed: CapBenchA | (((some CapBenchB or some CapBenchA) or some capBenchR) and renamed->renamed in capBenchR and (inv2 and ((some capBenchR and no CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap003084 { cap003084 iff cap003084c }
check CapBenchEquivalent_cap003084 for 4
