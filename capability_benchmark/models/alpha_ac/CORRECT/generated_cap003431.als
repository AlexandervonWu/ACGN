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
pred inv3 {
all x : Component | one y : Workstation | y in x.workstation
}

pred inv3c {
	all c : Component | one c.workstation
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003431 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))) and ((some capBenchR and no CapBenchB) or some CapBenchB)) }
pred cap003431c { all renamed: CapBenchA | (((some capBenchR and no CapBenchB) or some CapBenchB) and renamed->renamed in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003431 { cap003431 iff cap003431c }
check CapBenchEquivalent_cap003431 for 4
