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
pred inv1 {
all w:Worker | w in Human or w in Robot
}

pred inv1c {
	Worker = Human + Robot	
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002459 { ((inv1 and ((no CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) iff ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) }
pred cap002459c { (((not (inv1 and ((no CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) or ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) and ((not ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) or (inv1 and ((no CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap002459 { cap002459 iff cap002459c }
check CapBenchEquivalent_cap002459 for 4
