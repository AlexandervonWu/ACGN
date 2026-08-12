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

pred cap003565 { all x, y: CapBenchA | (x->y in capBenchR and (inv7 and ((some CapBenchB or some CapBenchA) or some CapBenchB))) }
pred cap003565c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv7 and ((some CapBenchB or some CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap003565 { cap003565 iff cap003565c }
check CapBenchEquivalent_cap003565 for 4
