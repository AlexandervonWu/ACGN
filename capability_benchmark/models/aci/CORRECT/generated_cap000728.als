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

pred cap000728 { ((inv5 and ((some capBenchR and some capBenchR) or no CapBenchB)) and ((some CapBenchB or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchA)) }
pred cap000728c { (((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchA) and (inv5 and ((some capBenchR and some capBenchR) or no CapBenchB)) and ((some CapBenchB or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) }
assert CapBenchEquivalent_cap000728 { cap000728 iff cap000728c }
check CapBenchEquivalent_cap000728 for 4
