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

pred cap004597 { not ((inv5 and ((some CapBenchB or some capBenchR) or some CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchR)) }
pred cap004597c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchR)) or (not (inv5 and ((some CapBenchB or some capBenchR) or some CapBenchB)))) }
assert CapBenchEquivalent_cap004597 { cap004597 iff cap004597c }
check CapBenchEquivalent_cap004597 for 4
