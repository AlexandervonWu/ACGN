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

pred cap005460 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv7 and ((some capBenchR and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB))) }
pred cap005460c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) or (not (inv7 and ((some capBenchR and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap005460 { cap005460 iff cap005460c }
check CapBenchEquivalent_cap005460 for 4
