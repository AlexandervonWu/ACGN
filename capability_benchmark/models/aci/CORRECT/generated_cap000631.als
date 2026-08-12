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
pred inv4 {
all p: Product - Material | some p.parts
all m: Material | no m.parts
}

pred inv4c {
	all c : Component | some c.parts
	all m : Material | no m.parts	

}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000631 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv4 and ((no CapBenchB or some CapBenchA) and no CapBenchA))) }
pred cap000631c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv4 and ((no CapBenchB or some CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap000631 { cap000631 iff cap000631c }
check CapBenchEquivalent_cap000631 for 4
