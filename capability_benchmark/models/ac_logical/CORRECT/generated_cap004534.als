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
pred inv7 {
all c : Component | all p : Product | p in Dangerous and p in c.parts implies c in Dangerous
}

pred inv7c {
	all c : Component | some c.parts & Dangerous implies c in Dangerous
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004534 { not ((inv7 and ((no CapBenchA and some capBenchR) and some CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchB)) }
pred cap004534c { ((not ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchB)) or (not (inv7 and ((no CapBenchA and some capBenchR) and some CapBenchA)))) }
assert CapBenchEquivalent_cap004534 { cap004534 iff cap004534c }
check CapBenchEquivalent_cap004534 for 4
