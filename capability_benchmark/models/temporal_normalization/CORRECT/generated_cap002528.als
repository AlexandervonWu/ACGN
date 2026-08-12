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

pred cap002528 { not (((inv1 and ((some capBenchR and no CapBenchB) or some CapBenchA))) until (((some CapBenchB or some CapBenchB) or no CapBenchB))) }
pred cap002528c { ((not (inv1 and ((some capBenchR and no CapBenchB) or some CapBenchA))) releases (not ((some CapBenchB or some CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap002528 { cap002528 iff cap002528c }
check CapBenchEquivalent_cap002528 for 4
