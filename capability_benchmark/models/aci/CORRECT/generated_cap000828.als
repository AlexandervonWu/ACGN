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

pred cap000828 { (some ((CapBenchA.capBenchR).capBenchR) and (inv3 and ((some CapBenchA and some CapBenchB) or some capBenchS))) }
pred cap000828c { (some (CapBenchA.(capBenchR.capBenchR)) and (inv3 and ((some CapBenchA and some CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap000828 { cap000828 iff cap000828c }
check CapBenchEquivalent_cap000828 for 4
