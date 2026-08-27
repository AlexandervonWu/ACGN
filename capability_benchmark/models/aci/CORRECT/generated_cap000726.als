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

pred cap000726 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv1 and ((no CapBenchA and some capBenchR) and no CapBenchB))) }
pred cap000726c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv1 and ((no CapBenchA and some capBenchR) and no CapBenchB))) }
assert CapBenchEquivalent_cap000726 { cap000726 iff cap000726c }
check CapBenchEquivalent_cap000726 for 4
