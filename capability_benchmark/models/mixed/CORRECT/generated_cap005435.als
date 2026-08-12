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

pred cap005435 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv7 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchA and some capBenchR) or some CapBenchB))) }
pred cap005435c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and some capBenchR) or some CapBenchB)) or (not (inv7 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005435 { cap005435 iff cap005435c }
check CapBenchEquivalent_cap005435 for 4
