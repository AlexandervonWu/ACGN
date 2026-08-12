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

pred cap004632 { not ((inv3 and ((some capBenchR and some CapBenchA) or no CapBenchA)) and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) }
pred cap004632c { ((not ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) or (not (inv3 and ((some capBenchR and some CapBenchA) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004632 { cap004632 iff cap004632c }
check CapBenchEquivalent_cap004632 for 4
