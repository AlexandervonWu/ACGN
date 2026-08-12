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
all w : Worker | w in Human + Robot
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

pred cap003950 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((no CapBenchA and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap003950c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((no CapBenchA and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003950 { cap003950 iff cap003950c }
check CapBenchEquivalent_cap003950 for 4
