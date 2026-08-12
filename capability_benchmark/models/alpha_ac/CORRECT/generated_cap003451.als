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
pred inv7 {
all c : Component | all p : Product | p in Dangerous and p in c.parts implies c in Dangerous
}

pred inv7c {
	all c : Component | some c.parts & Dangerous implies c in Dangerous
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003451 { all x: CapBenchA | (x->x in capBenchR and (inv7 and ((no CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) }
pred cap003451c { all renamed: CapBenchA | (((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB) and renamed->renamed in capBenchR and (inv7 and ((no CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003451 { cap003451 iff cap003451c }
check CapBenchEquivalent_cap003451 for 4
