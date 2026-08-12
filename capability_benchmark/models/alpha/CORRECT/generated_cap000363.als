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

pred cap000363 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv5 and ((no CapBenchB or some capBenchS) and some capBenchS))) }
pred cap000363c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv5 and ((no CapBenchB or some capBenchS) and some capBenchS))) }
assert CapBenchEquivalent_cap000363 { cap000363 iff cap000363c }
check CapBenchEquivalent_cap000363 for 4
