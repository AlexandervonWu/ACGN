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

pred cap002029 { no x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchS or no CapBenchB) or some CapBenchA))) }
pred cap002029c { all x: CapBenchA | not (x->x in capBenchR and (inv1 and ((some capBenchS or no CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap002029 { cap002029 iff cap002029c }
check CapBenchEquivalent_cap002029 for 4
