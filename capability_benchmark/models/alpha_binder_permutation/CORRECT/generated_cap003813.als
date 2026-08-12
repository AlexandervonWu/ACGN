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

pred cap003813 { all x, y: CapBenchA | (x->y in capBenchR and (inv5 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
pred cap003813c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv5 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap003813 { cap003813 iff cap003813c }
check CapBenchEquivalent_cap003813 for 4
