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

pred cap004394 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv5 and ((no CapBenchA and some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap004394c { some a, b: CapBenchA | (b->a in capBenchR and (inv5 and ((no CapBenchA and some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap004394 { cap004394 iff cap004394c }
check CapBenchEquivalent_cap004394 for 4
