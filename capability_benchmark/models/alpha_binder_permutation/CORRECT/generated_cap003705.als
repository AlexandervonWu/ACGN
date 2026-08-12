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
(all w: Workstation | some r: Worker | r in w.workers) && (all w: Worker | one workers.w)
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

pred cap003705 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((some capBenchS or some CapBenchB) or no CapBenchB))) }
pred cap003705c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv2 and ((some capBenchS or some CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap003705 { cap003705 iff cap003705c }
check CapBenchEquivalent_cap003705 for 4
