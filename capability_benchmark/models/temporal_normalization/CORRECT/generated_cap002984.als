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

pred cap002984 { not (((inv1 and ((some capBenchR and some capBenchR) or CapBenchA in CapBenchA + CapBenchB))) until (((some CapBenchB or no CapBenchA) or no CapBenchA))) }
pred cap002984c { ((not (inv1 and ((some capBenchR and some capBenchR) or CapBenchA in CapBenchA + CapBenchB))) releases (not ((some CapBenchB or no CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap002984 { cap002984 iff cap002984c }
check CapBenchEquivalent_cap002984 for 4
