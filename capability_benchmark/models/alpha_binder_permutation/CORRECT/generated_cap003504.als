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

pred cap003504 { all x, y: CapBenchA | (x->y in capBenchR and (inv3 and ((some capBenchR and some CapBenchA) or some CapBenchA))) }
pred cap003504c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv3 and ((some capBenchR and some CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap003504 { cap003504 iff cap003504c }
check CapBenchEquivalent_cap003504 for 4
