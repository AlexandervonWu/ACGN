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

pred cap005023 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv7 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchA)) and ((some capBenchR and some CapBenchA) or no CapBenchB))) }
pred cap005023c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and some CapBenchA) or no CapBenchB)) or (not (inv7 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchA)))) }
assert CapBenchEquivalent_cap005023 { cap005023 iff cap005023c }
check CapBenchEquivalent_cap005023 for 4
