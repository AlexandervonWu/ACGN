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

pred cap004648 { not ((inv5 and ((some capBenchR and no CapBenchA) or no CapBenchA)) and ((some CapBenchB or some CapBenchA) or some capBenchS)) }
pred cap004648c { ((not ((some CapBenchB or some CapBenchA) or some capBenchS)) or (not (inv5 and ((some capBenchR and no CapBenchA) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004648 { cap004648 iff cap004648c }
check CapBenchEquivalent_cap004648 for 4
