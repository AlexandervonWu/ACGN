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

pred cap003718 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((no CapBenchA and no CapBenchB) and no CapBenchB))) }
pred cap003718c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((no CapBenchA and no CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap003718 { cap003718 iff cap003718c }
check CapBenchEquivalent_cap003718 for 4
