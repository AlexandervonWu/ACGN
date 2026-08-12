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

pred cap003027 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((no CapBenchB or no CapBenchB) and some CapBenchA)) and ((some CapBenchA and some CapBenchB) or no CapBenchB)) }
pred cap003027c { all renamed: CapBenchA | (((some CapBenchA and some CapBenchB) or no CapBenchB) and renamed->renamed in capBenchR and (inv3 and ((no CapBenchB or no CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap003027 { cap003027 iff cap003027c }
check CapBenchEquivalent_cap003027 for 4
