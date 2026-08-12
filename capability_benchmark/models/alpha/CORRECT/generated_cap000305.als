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

pred cap000305 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv3 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR))) }
pred cap000305c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv3 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR))) }
assert CapBenchEquivalent_cap000305 { cap000305 iff cap000305c }
check CapBenchEquivalent_cap000305 for 4
