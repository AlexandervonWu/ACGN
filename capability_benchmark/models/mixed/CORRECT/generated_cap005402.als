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

pred cap005402 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((no CapBenchA and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchA))) }
pred cap005402c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchA)) or (not (inv1 and ((no CapBenchA and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005402 { cap005402 iff cap005402c }
check CapBenchEquivalent_cap005402 for 4
