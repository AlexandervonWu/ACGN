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

pred cap005112 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv7 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) and ((some capBenchS or no CapBenchB) or some capBenchR))) }
pred cap005112c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or no CapBenchB) or some capBenchR)) or (not (inv7 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)))) }
assert CapBenchEquivalent_cap005112 { cap005112 iff cap005112c }
check CapBenchEquivalent_cap005112 for 4
