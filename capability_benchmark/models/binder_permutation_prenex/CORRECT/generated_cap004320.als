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

pred cap004320 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv2 and ((some CapBenchA and some CapBenchA) or some capBenchS))) }
pred cap004320c { some a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some CapBenchA and some CapBenchA) or some capBenchS))) }
assert CapBenchEquivalent_cap004320 { cap004320 iff cap004320c }
check CapBenchEquivalent_cap004320 for 4
