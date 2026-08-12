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

pred cap005345 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((some CapBenchB or no CapBenchB) or some capBenchS)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchA))) }
pred cap005345c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchA)) or (not (inv3 and ((some CapBenchB or no CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap005345 { cap005345 iff cap005345c }
check CapBenchEquivalent_cap005345 for 4
