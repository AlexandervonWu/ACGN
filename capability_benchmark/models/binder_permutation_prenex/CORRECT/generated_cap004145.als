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
all wtt : Workstation | some wtt.workers
all w : Worker | one wtt : Workstation | w in wtt.workers
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

pred cap004145 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv2 and ((some CapBenchB or no CapBenchA) or no CapBenchA))) }
pred cap004145c { some a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some CapBenchB or no CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap004145 { cap004145 iff cap004145c }
check CapBenchEquivalent_cap004145 for 4
