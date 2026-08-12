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

pred cap005068 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((some capBenchR and some CapBenchA) or some CapBenchB)) and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB))) }
pred cap005068c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) or (not (inv4 and ((some capBenchR and some CapBenchA) or some CapBenchB)))) }
assert CapBenchEquivalent_cap005068 { cap005068 iff cap005068c }
check CapBenchEquivalent_cap005068 for 4
