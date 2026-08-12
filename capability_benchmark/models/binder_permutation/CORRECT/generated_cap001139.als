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

pred cap001139 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv2 and ((no CapBenchB or some CapBenchB) and no CapBenchA))) }
pred cap001139c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv2 and ((no CapBenchB or some CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap001139 { cap001139 iff cap001139c }
check CapBenchEquivalent_cap001139 for 4
