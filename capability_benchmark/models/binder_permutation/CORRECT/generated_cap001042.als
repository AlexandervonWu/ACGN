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

pred cap001042 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((no CapBenchA and some capBenchS) and some CapBenchA))) }
pred cap001042c { all a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((no CapBenchA and some capBenchS) and some CapBenchA))) }
assert CapBenchEquivalent_cap001042 { cap001042 iff cap001042c }
check CapBenchEquivalent_cap001042 for 4
