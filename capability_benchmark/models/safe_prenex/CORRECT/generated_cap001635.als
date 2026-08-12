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

pred cap001635 { ((all x: CapBenchA | x->x in capBenchR) or (inv7 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchA))) }
pred cap001635c { (all x: CapBenchA | (x->x in capBenchR or (inv7 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchA)))) }
assert CapBenchEquivalent_cap001635 { cap001635 iff cap001635c }
check CapBenchEquivalent_cap001635 for 4
