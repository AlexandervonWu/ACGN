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

pred cap005243 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv5 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB)) and ((some CapBenchA and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005243c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv5 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB)))) }
assert CapBenchEquivalent_cap005243 { cap005243 iff cap005243c }
check CapBenchEquivalent_cap005243 for 4
