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

pred cap002845 { not once ((inv3 and ((some CapBenchB or no CapBenchB) or some capBenchS))) }
pred cap002845c { historically (not (inv3 and ((some CapBenchB or no CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap002845 { cap002845 iff cap002845c }
check CapBenchEquivalent_cap002845 for 4
