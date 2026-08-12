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

pred cap003071 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchB)) and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) }
pred cap003071c { all renamed: CapBenchA | (((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB) and renamed->renamed in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap003071 { cap003071 iff cap003071c }
check CapBenchEquivalent_cap003071 for 4
