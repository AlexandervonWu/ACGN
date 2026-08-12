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

pred cap003219 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((no CapBenchB or no CapBenchB) and no CapBenchB)) and ((some CapBenchA and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003219c { all renamed: CapBenchA | (((some CapBenchA and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv4 and ((no CapBenchB or no CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap003219 { cap003219 iff cap003219c }
check CapBenchEquivalent_cap003219 for 4
