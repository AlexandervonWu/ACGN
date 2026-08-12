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

pred cap005094 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchB)) and ((no CapBenchB or some CapBenchB) and some capBenchR))) }
pred cap005094c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or some CapBenchB) and some capBenchR)) or (not (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchB)))) }
assert CapBenchEquivalent_cap005094 { cap005094 iff cap005094c }
check CapBenchEquivalent_cap005094 for 4
