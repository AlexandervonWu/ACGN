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

pred cap003584 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((some capBenchR and no CapBenchA) or some CapBenchB))) }
pred cap003584c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((some capBenchR and no CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap003584 { cap003584 iff cap003584c }
check CapBenchEquivalent_cap003584 for 4
