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

pred cap005381 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) and ((no CapBenchA and some capBenchS) and some CapBenchA))) }
pred cap005381c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and some capBenchS) and some CapBenchA)) or (not (inv3 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap005381 { cap005381 iff cap005381c }
check CapBenchEquivalent_cap005381 for 4
