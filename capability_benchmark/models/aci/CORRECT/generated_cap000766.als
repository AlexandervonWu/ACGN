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

pred cap000766 { (inv2 and ((no CapBenchA and some CapBenchB) and some capBenchR)) }
pred cap000766c { ((inv2 and ((no CapBenchA and some CapBenchB) and some capBenchR)) and (inv2 and ((no CapBenchA and some CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap000766 { cap000766 iff cap000766c }
check CapBenchEquivalent_cap000766 for 4
