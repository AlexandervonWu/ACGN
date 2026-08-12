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

pred cap003009 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some CapBenchB or some CapBenchB) or some CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)) }
pred cap003009c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA) and renamed->renamed in capBenchR and (inv2 and ((some CapBenchB or some CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap003009 { cap003009 iff cap003009c }
check CapBenchEquivalent_cap003009 for 4
