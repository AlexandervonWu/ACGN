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

pred cap001275 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv9 and ((no CapBenchB or no CapBenchA) and some capBenchR))) }
pred cap001275c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv9 and ((no CapBenchB or no CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap001275 { cap001275 iff cap001275c }
check CapBenchEquivalent_cap001275 for 4
