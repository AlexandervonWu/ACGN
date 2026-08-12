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

pred cap004452 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((some capBenchR and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap004452c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((some capBenchR and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap004452 { cap004452 iff cap004452c }
check CapBenchEquivalent_cap004452 for 4
