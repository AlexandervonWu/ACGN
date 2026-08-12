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

pred cap002242 { ((inv2 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB)) implies ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap002242c { ((not (inv2 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB))) or ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) }
assert CapBenchEquivalent_cap002242 { cap002242 iff cap002242c }
check CapBenchEquivalent_cap002242 for 4
