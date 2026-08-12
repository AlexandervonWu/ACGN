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

pred cap001381 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv2 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
pred cap001381c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv2 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap001381 { cap001381 iff cap001381c }
check CapBenchEquivalent_cap001381 for 4
