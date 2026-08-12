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

pred cap000144 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv2 and ((some CapBenchA and no CapBenchA) or no CapBenchA))) }
pred cap000144c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv2 and ((some CapBenchA and no CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap000144 { cap000144 iff cap000144c }
check CapBenchEquivalent_cap000144 for 4
