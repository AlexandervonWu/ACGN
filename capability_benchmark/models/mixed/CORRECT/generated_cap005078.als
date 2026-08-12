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
pred inv9 {
all w : Workstation | (no succ.w <=> w in begin) and (no w.succ <=> w in end) and lone w.succ
no (^succ & iden)
}

pred inv9c {
	all w : Workstation - end | one w.succ
	no end.succ
	Workstation in begin.*succ
}

check correct { inv9 <=> inv9c}
pred under { inv9 and !inv9c}
pred over { !inv9 and inv9c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005078 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv9 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchB)) and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB))) }
pred cap005078c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB)) or (not (inv9 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchB)))) }
assert CapBenchEquivalent_cap005078 { cap005078 iff cap005078c }
check CapBenchEquivalent_cap005078 for 4
