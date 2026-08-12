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

pred cap002720 { not (((inv3 and ((some capBenchR and no CapBenchB) or no CapBenchB))) until (((some CapBenchB or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap002720c { ((not (inv3 and ((some capBenchR and no CapBenchB) or no CapBenchB))) releases (not ((some CapBenchB or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002720 { cap002720 iff cap002720c }
check CapBenchEquivalent_cap002720 for 4
