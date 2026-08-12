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
all w:Workstation, h:Human, r:Robot | h not in w.workers or r not in w.workers
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

pred cap001510 { ((some x: CapBenchA | x->x in capBenchR) and (inv5 and ((no CapBenchA and some CapBenchB) and some CapBenchA))) }
pred cap001510c { (some x: CapBenchA | (x->x in capBenchR and (inv5 and ((no CapBenchA and some CapBenchB) and some CapBenchA)))) }
assert CapBenchEquivalent_cap001510 { cap001510 iff cap001510c }
check CapBenchEquivalent_cap001510 for 4
