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

pred cap002608 { not always ((inv3 and ((some capBenchR and some capBenchS) or some CapBenchB))) }
pred cap002608c { eventually (not (inv3 and ((some capBenchR and some capBenchS) or some CapBenchB))) }
assert CapBenchEquivalent_cap002608 { cap002608 iff cap002608c }
check CapBenchEquivalent_cap002608 for 4
