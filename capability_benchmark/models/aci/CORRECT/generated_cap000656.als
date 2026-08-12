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

pred cap000656 { ((inv2 and ((some capBenchR and no CapBenchB) or no CapBenchA)) and ((some CapBenchB or some CapBenchB) or some capBenchS) and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap000656c { (((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB) and (inv2 and ((some capBenchR and no CapBenchB) or no CapBenchA)) and ((some CapBenchB or some CapBenchB) or some capBenchS)) }
assert CapBenchEquivalent_cap000656 { cap000656 iff cap000656c }
check CapBenchEquivalent_cap000656 for 4
