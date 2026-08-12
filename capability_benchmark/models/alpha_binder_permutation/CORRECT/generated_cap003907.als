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

pred cap003907 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap003907c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003907 { cap003907 iff cap003907c }
check CapBenchEquivalent_cap003907 for 4
