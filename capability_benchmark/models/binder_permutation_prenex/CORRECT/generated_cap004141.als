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

pred cap004141 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv7 and ((some capBenchS or some CapBenchB) or no CapBenchA))) }
pred cap004141c { some a, b: CapBenchA | (b->a in capBenchR and (inv7 and ((some capBenchS or some CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap004141 { cap004141 iff cap004141c }
check CapBenchEquivalent_cap004141 for 4
