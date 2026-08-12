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

pred cap003065 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((some CapBenchB or some CapBenchA) or some CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchB)) }
pred cap003065c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchB) and renamed->renamed in capBenchR and (inv3 and ((some CapBenchB or some CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap003065 { cap003065 iff cap003065c }
check CapBenchEquivalent_cap003065 for 4
