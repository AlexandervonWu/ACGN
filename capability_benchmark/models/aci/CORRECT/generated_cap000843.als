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

all ws : Workstation | some ws.workers
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

pred cap000843 { ((inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchS)) or ((some capBenchR and some CapBenchA) or some CapBenchA) or ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)) }
pred cap000843c { (((some capBenchR and some CapBenchA) or some CapBenchA) or ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA) or (inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap000843 { cap000843 iff cap000843c }
check CapBenchEquivalent_cap000843 for 4
