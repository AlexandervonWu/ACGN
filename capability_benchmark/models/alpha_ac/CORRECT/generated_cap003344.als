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

pred cap003344 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some CapBenchA and no CapBenchB) or some capBenchS)) and ((some capBenchS or some CapBenchA) or some CapBenchA)) }
pred cap003344c { all renamed: CapBenchA | (((some capBenchS or some CapBenchA) or some CapBenchA) and renamed->renamed in capBenchR and (inv2 and ((some CapBenchA and no CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap003344 { cap003344 iff cap003344c }
check CapBenchEquivalent_cap003344 for 4
