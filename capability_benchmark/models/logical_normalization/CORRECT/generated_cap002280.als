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

pred cap002280 { not (all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some CapBenchA and no CapBenchB) or some capBenchR)))) }
pred cap002280c { some x: CapBenchA | not (x->x in capBenchR and (inv1 and ((some CapBenchA and no CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap002280 { cap002280 iff cap002280c }
check CapBenchEquivalent_cap002280 for 4
