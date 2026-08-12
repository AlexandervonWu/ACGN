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
pred inv2 {
workers in Workstation one -> some Worker
}

pred inv2c {
	workers in Workstation one -> some Worker
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004859 { not ((inv2 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchS)) and ((some capBenchR and no CapBenchA) or some CapBenchA)) }
pred cap004859c { ((not ((some capBenchR and no CapBenchA) or some CapBenchA)) or (not (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchS)))) }
assert CapBenchEquivalent_cap004859 { cap004859 iff cap004859c }
check CapBenchEquivalent_cap004859 for 4
