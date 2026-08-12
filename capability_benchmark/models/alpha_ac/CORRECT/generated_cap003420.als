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

pred cap003420 { all x: CapBenchA | (x->x in capBenchR and (inv5 and ((some capBenchR and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchB or no CapBenchA) or some CapBenchB)) }
pred cap003420c { all renamed: CapBenchA | (((some CapBenchB or no CapBenchA) or some CapBenchB) and renamed->renamed in capBenchR and (inv5 and ((some capBenchR and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003420 { cap003420 iff cap003420c }
check CapBenchEquivalent_cap003420 for 4
