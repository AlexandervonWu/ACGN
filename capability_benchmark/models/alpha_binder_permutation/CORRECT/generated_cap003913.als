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

pred cap003913 { all x, y: CapBenchA | (x->y in capBenchR and (inv5 and ((some capBenchS or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap003913c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv5 and ((some capBenchS or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003913 { cap003913 iff cap003913c }
check CapBenchEquivalent_cap003913 for 4
