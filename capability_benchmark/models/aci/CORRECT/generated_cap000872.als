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
pred inv5 {
no workers.Human & workers.Robot
}

pred inv5c {
	all c : Workstation | no (c.workers & Human) or no (c.workers & Robot)
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000872 { ((inv5 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) and ((some CapBenchB or some capBenchR) or some CapBenchA) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchB)) }
pred cap000872c { (((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchB) and (inv5 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) and ((some CapBenchB or some capBenchR) or some CapBenchA)) }
assert CapBenchEquivalent_cap000872 { cap000872 iff cap000872c }
check CapBenchEquivalent_cap000872 for 4
