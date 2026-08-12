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
(all ws: Workstation | some ws.workers) and (all w: Worker | one workers.w)
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

pred cap003349 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some capBenchS or no CapBenchB) or some capBenchS)) and ((no CapBenchA and some CapBenchB) and some CapBenchA)) }
pred cap003349c { all renamed: CapBenchA | (((no CapBenchA and some CapBenchB) and some CapBenchA) and renamed->renamed in capBenchR and (inv2 and ((some capBenchS or no CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap003349 { cap003349 iff cap003349c }
check CapBenchEquivalent_cap003349 for 4
