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

pred cap003301 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchS or some capBenchS) or some capBenchR)) and ((no CapBenchA and no CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap003301c { all renamed: CapBenchA | (((no CapBenchA and no CapBenchB) and CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv4 and ((some capBenchS or some capBenchS) or some capBenchR))) }
assert CapBenchEquivalent_cap003301 { cap003301 iff cap003301c }
check CapBenchEquivalent_cap003301 for 4
