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

pred cap003652 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((some CapBenchA and no CapBenchB) or no CapBenchA))) }
pred cap003652c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((some CapBenchA and no CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap003652 { cap003652 iff cap003652c }
check CapBenchEquivalent_cap003652 for 4
