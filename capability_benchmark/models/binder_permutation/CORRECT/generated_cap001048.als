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
all wk:Workstation | some w:Worker | w in wk.workers
all w:Worker | one wk:Workstation | w in wk.workers
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

pred cap001048 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
pred cap001048c { all a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
assert CapBenchEquivalent_cap001048 { cap001048 iff cap001048c }
check CapBenchEquivalent_cap001048 for 4
