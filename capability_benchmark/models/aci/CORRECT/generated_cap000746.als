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

pred cap000746 { ((inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB)) and ((no CapBenchB or some capBenchR) and capBenchR in (CapBenchA -> CapBenchA)) and ((some CapBenchB or no CapBenchA) or some CapBenchB)) }
pred cap000746c { (((some CapBenchB or no CapBenchA) or some CapBenchB) and (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB)) and ((no CapBenchB or some capBenchR) and capBenchR in (CapBenchA -> CapBenchA))) }
assert CapBenchEquivalent_cap000746 { cap000746 iff cap000746c }
check CapBenchEquivalent_cap000746 for 4
