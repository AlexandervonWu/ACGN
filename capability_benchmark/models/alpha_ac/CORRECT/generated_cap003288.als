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

pred cap003288 { all x: CapBenchA | (x->x in capBenchR and (inv7 and ((some CapBenchA and some capBenchR) or some capBenchR)) and ((some capBenchS or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap003288c { all renamed: CapBenchA | (((some capBenchS or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv7 and ((some CapBenchA and some capBenchR) or some capBenchR))) }
assert CapBenchEquivalent_cap003288 { cap003288 iff cap003288c }
check CapBenchEquivalent_cap003288 for 4
