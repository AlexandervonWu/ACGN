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

pred cap002184 { not (all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)))) }
pred cap002184c { some x: CapBenchA | not (x->x in capBenchR and (inv2 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap002184 { cap002184 iff cap002184c }
check CapBenchEquivalent_cap002184 for 4
