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

pred cap000772 { (inv7 and ((some CapBenchA and no CapBenchA) or some capBenchR)) }
pred cap000772c { ((inv7 and ((some CapBenchA and no CapBenchA) or some capBenchR)) and (inv7 and ((some CapBenchA and no CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap000772 { cap000772 iff cap000772c }
check CapBenchEquivalent_cap000772 for 4
