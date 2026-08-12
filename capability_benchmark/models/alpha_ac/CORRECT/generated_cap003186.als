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

pred cap003186 { all x: CapBenchA | (x->x in capBenchR and (inv5 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchS)) }
pred cap003186c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchS) and renamed->renamed in capBenchR and (inv5 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap003186 { cap003186 iff cap003186c }
check CapBenchEquivalent_cap003186 for 4
