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

pred cap003339 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((no CapBenchB or no CapBenchA) and some capBenchS)) and ((some CapBenchA and some CapBenchA) or some CapBenchA)) }
pred cap003339c { all renamed: CapBenchA | (((some CapBenchA and some CapBenchA) or some CapBenchA) and renamed->renamed in capBenchR and (inv4 and ((no CapBenchB or no CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap003339 { cap003339 iff cap003339c }
check CapBenchEquivalent_cap003339 for 4
