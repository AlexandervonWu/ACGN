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
all c : Component | one c.workstation
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

pred cap000674 { ((inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchA)) and ((no CapBenchB or no CapBenchB) and some capBenchS) and ((some CapBenchB or some CapBenchB) or some CapBenchA)) }
pred cap000674c { (((some CapBenchB or some CapBenchB) or some CapBenchA) and (inv3 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchA)) and ((no CapBenchB or no CapBenchB) and some capBenchS)) }
assert CapBenchEquivalent_cap000674 { cap000674 iff cap000674c }
check CapBenchEquivalent_cap000674 for 4
