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

pred cap000621 { ((inv3 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) or ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchR) or ((some capBenchR and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap000621c { (((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchR) or ((some capBenchR and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB) or (inv3 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap000621 { cap000621 iff cap000621c }
check CapBenchEquivalent_cap000621 for 4
