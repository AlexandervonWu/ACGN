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
(all w: Workstation | some r: Worker | r in w.workers) && (all w: Worker | one workers.w)
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

pred cap000431 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap000431c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000431 { cap000431 iff cap000431c }
check CapBenchEquivalent_cap000431 for 4
