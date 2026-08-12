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

pred cap003028 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some capBenchR and no CapBenchB) or some CapBenchA)) and ((some CapBenchB or some CapBenchB) or no CapBenchB)) }
pred cap003028c { all renamed: CapBenchA | (((some CapBenchB or some CapBenchB) or no CapBenchB) and renamed->renamed in capBenchR and (inv2 and ((some capBenchR and no CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap003028 { cap003028 iff cap003028c }
check CapBenchEquivalent_cap003028 for 4
