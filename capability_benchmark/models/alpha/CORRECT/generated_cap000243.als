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

pred cap000243 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv2 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB))) }
pred cap000243c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv2 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB))) }
assert CapBenchEquivalent_cap000243 { cap000243 iff cap000243c }
check CapBenchEquivalent_cap000243 for 4
