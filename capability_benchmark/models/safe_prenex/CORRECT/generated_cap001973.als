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

pred cap001973 { ((all x: CapBenchA | x->x in capBenchR) or (inv5 and ((some CapBenchB or no CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap001973c { (all x: CapBenchA | (x->x in capBenchR or (inv5 and ((some CapBenchB or no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap001973 { cap001973 iff cap001973c }
check CapBenchEquivalent_cap001973 for 4
