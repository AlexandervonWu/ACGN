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
all wk:Workstation | some w:Worker | w in wk.workers
all w:Worker | one wk:Workstation | w in wk.workers
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

pred cap005101 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((some capBenchS or some capBenchR) or some CapBenchB)) and ((no CapBenchA and no CapBenchA) and some capBenchR))) }
pred cap005101c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and no CapBenchA) and some capBenchR)) or (not (inv2 and ((some capBenchS or some capBenchR) or some CapBenchB)))) }
assert CapBenchEquivalent_cap005101 { cap005101 iff cap005101c }
check CapBenchEquivalent_cap005101 for 4
