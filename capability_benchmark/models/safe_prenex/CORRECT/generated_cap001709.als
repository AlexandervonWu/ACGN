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

pred cap001709 { ((all x: CapBenchA | x->x in capBenchR) or (inv7 and ((some CapBenchB or no CapBenchA) or no CapBenchB))) }
pred cap001709c { (all x: CapBenchA | (x->x in capBenchR or (inv7 and ((some CapBenchB or no CapBenchA) or no CapBenchB)))) }
assert CapBenchEquivalent_cap001709 { cap001709 iff cap001709c }
check CapBenchEquivalent_cap001709 for 4
