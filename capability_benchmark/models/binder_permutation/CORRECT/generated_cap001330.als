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

pred cap001330 { all x, y: CapBenchA | (x->y in capBenchR and (inv3 and ((no CapBenchA and some CapBenchB) and some capBenchS))) }
pred cap001330c { all a, b: CapBenchA | (b->a in capBenchR and (inv3 and ((no CapBenchA and some CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap001330 { cap001330 iff cap001330c }
check CapBenchEquivalent_cap001330 for 4
