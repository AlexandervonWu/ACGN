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
all x: Component | some x.parts
all x : Material | no x.parts
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

pred cap004458 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv4 and ((no CapBenchA and some CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap004458c { some a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((no CapBenchA and some CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap004458 { cap004458 iff cap004458c }
check CapBenchEquivalent_cap004458 for 4
