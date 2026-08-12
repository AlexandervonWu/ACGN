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

pred cap002157 { not ((inv5 and ((some capBenchS or no CapBenchB) or no CapBenchA)) and ((no CapBenchA and some CapBenchB) and some capBenchS)) }
pred cap002157c { ((not (inv5 and ((some capBenchS or no CapBenchB) or no CapBenchA))) or (not ((no CapBenchA and some CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap002157 { cap002157 iff cap002157c }
check CapBenchEquivalent_cap002157 for 4
