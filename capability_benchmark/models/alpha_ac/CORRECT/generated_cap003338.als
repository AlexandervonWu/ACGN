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

pred cap003338 { all x: CapBenchA | (x->x in capBenchR and (inv7 and ((no CapBenchA and no CapBenchA) and some capBenchS)) and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap003338c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv7 and ((no CapBenchA and no CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap003338 { cap003338 iff cap003338c }
check CapBenchEquivalent_cap003338 for 4
