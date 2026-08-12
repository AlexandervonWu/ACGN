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
all c: Component | all x: c.parts | x in Dangerous => c in Dangerous
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

pred cap004590 { not ((inv7 and ((no CapBenchA and no CapBenchB) and some CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchR)) }
pred cap004590c { ((not ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchR)) or (not (inv7 and ((no CapBenchA and no CapBenchB) and some CapBenchB)))) }
assert CapBenchEquivalent_cap004590 { cap004590 iff cap004590c }
check CapBenchEquivalent_cap004590 for 4
