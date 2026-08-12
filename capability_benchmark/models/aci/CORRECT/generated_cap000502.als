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

pred cap000502 { (inv4 and ((no CapBenchA and some CapBenchA) and some CapBenchA)) }
pred cap000502c { ((inv4 and ((no CapBenchA and some CapBenchA) and some CapBenchA)) and (inv4 and ((no CapBenchA and some CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap000502 { cap000502 iff cap000502c }
check CapBenchEquivalent_cap000502 for 4
