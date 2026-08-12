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
all c: Component | one c.workstation
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

pred cap005452 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((some capBenchR and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB))) }
pred cap005452c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) or (not (inv3 and ((some capBenchR and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap005452 { cap005452 iff cap005452c }
check CapBenchEquivalent_cap005452 for 4
