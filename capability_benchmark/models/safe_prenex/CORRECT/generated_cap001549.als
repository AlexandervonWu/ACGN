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

pred cap001549 { ((all x: CapBenchA | x->x in capBenchR) or (inv4 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
pred cap001549c { (all x: CapBenchA | (x->x in capBenchR or (inv4 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)))) }
assert CapBenchEquivalent_cap001549 { cap001549 iff cap001549c }
check CapBenchEquivalent_cap001549 for 4
