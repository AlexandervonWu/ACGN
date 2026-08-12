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

pred cap004716 { not ((inv3 and ((some CapBenchA and no CapBenchB) or no CapBenchB)) and ((some capBenchS or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004716c { ((not ((some capBenchS or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv3 and ((some CapBenchA and no CapBenchB) or no CapBenchB)))) }
assert CapBenchEquivalent_cap004716 { cap004716 iff cap004716c }
check CapBenchEquivalent_cap004716 for 4
