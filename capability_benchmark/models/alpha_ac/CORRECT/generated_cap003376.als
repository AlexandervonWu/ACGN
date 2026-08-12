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

pred cap003376 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) and ((some capBenchS or some capBenchR) or some CapBenchA)) }
pred cap003376c { all renamed: CapBenchA | (((some capBenchS or some capBenchR) or some CapBenchA) and renamed->renamed in capBenchR and (inv4 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap003376 { cap003376 iff cap003376c }
check CapBenchEquivalent_cap003376 for 4
