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

pred cap000777 { ((inv2 and ((some capBenchS or no CapBenchA) or some capBenchR)) or ((no CapBenchA and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB) or ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) }
pred cap000777c { (((no CapBenchA and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB) or ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB) or (inv2 and ((some capBenchS or no CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap000777 { cap000777 iff cap000777c }
check CapBenchEquivalent_cap000777 for 4
