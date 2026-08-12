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

pred cap001806 { ((some x: CapBenchA | x->x in capBenchR) and (inv2 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR))) }
pred cap001806c { (some x: CapBenchA | (x->x in capBenchR and (inv2 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR)))) }
assert CapBenchEquivalent_cap001806 { cap001806 iff cap001806c }
check CapBenchEquivalent_cap001806 for 4
