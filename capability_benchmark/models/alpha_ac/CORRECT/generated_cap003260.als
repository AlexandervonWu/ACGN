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

pred cap003260 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((some capBenchR and some CapBenchA) or some capBenchR)) and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003260c { all renamed: CapBenchA | (((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv3 and ((some capBenchR and some CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap003260 { cap003260 iff cap003260c }
check CapBenchEquivalent_cap003260 for 4
