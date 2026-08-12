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

pred cap004847 { not ((inv4 and ((no CapBenchB or no CapBenchB) and some capBenchS)) and ((some CapBenchA and some CapBenchB) or some CapBenchA)) }
pred cap004847c { ((not ((some CapBenchA and some CapBenchB) or some CapBenchA)) or (not (inv4 and ((no CapBenchB or no CapBenchB) and some capBenchS)))) }
assert CapBenchEquivalent_cap004847 { cap004847 iff cap004847c }
check CapBenchEquivalent_cap004847 for 4
