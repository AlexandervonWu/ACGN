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

pred cap002863 { not once ((inv7 and ((no CapBenchB or some capBenchS) and some capBenchS))) }
pred cap002863c { historically (not (inv7 and ((no CapBenchB or some capBenchS) and some capBenchS))) }
assert CapBenchEquivalent_cap002863 { cap002863 iff cap002863c }
check CapBenchEquivalent_cap002863 for 4
