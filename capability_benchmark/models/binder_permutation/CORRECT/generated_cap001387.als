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
pred inv5 {
all w:Workstation, h:Human, r:Robot | h not in w.workers or r not in w.workers
}

pred inv5c {
	all c : Workstation | no (c.workers & Human) or no (c.workers & Robot)
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001387 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv5 and ((no CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001387c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv5 and ((no CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap001387 { cap001387 iff cap001387c }
check CapBenchEquivalent_cap001387 for 4
