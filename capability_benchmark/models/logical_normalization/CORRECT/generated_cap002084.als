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

pred cap002084 { not not ((inv3 and ((some capBenchR and no CapBenchA) or some CapBenchB))) }
pred cap002084c { (inv3 and ((some capBenchR and no CapBenchA) or some CapBenchB)) }
assert CapBenchEquivalent_cap002084 { cap002084 iff cap002084c }
check CapBenchEquivalent_cap002084 for 4
