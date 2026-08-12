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

pred cap004860 { not ((inv7 and ((some CapBenchA and some capBenchS) or some capBenchS)) and ((some capBenchS or no CapBenchA) or some CapBenchA)) }
pred cap004860c { ((not ((some capBenchS or no CapBenchA) or some CapBenchA)) or (not (inv7 and ((some CapBenchA and some capBenchS) or some capBenchS)))) }
assert CapBenchEquivalent_cap004860 { cap004860 iff cap004860c }
check CapBenchEquivalent_cap004860 for 4
