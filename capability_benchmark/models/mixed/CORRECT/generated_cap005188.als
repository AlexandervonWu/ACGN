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

pred cap005188 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)) and ((some CapBenchB or some capBenchS) or some capBenchS))) }
pred cap005188c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or some capBenchS) or some capBenchS)) or (not (inv2 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)))) }
assert CapBenchEquivalent_cap005188 { cap005188 iff cap005188c }
check CapBenchEquivalent_cap005188 for 4
