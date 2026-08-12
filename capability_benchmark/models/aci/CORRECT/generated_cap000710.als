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
all c : Component | some c.parts
iden not in parts
no Material.parts
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

pred cap000710 { ((inv4 and ((no CapBenchA and no CapBenchA) and no CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS) and ((some capBenchS or some capBenchS) or some CapBenchA)) }
pred cap000710c { (((some capBenchS or some capBenchS) or some CapBenchA) and (inv4 and ((no CapBenchA and no CapBenchA) and no CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchS)) }
assert CapBenchEquivalent_cap000710 { cap000710 iff cap000710c }
check CapBenchEquivalent_cap000710 for 4
