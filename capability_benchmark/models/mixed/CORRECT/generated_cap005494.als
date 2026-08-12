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

pred cap005494 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and CapBenchA in CapBenchA + CapBenchB)) and ((no CapBenchB or no CapBenchB) and no CapBenchA))) }
pred cap005494c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or no CapBenchB) and no CapBenchA)) or (not (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap005494 { cap005494 iff cap005494c }
check CapBenchEquivalent_cap005494 for 4
