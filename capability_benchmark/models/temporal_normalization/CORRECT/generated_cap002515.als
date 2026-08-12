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

pred cap002515 { not once ((inv1 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchA))) }
pred cap002515c { historically (not (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap002515 { cap002515 iff cap002515c }
check CapBenchEquivalent_cap002515 for 4
