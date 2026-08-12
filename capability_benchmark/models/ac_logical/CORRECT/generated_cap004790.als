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
all w:Worker | w in Human+Robot
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

pred cap004790 { not ((inv1 and ((no CapBenchA and some capBenchR) and some capBenchR)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap004790c { ((not ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv1 and ((no CapBenchA and some capBenchR) and some capBenchR)))) }
assert CapBenchEquivalent_cap004790 { cap004790 iff cap004790c }
check CapBenchEquivalent_cap004790 for 4
