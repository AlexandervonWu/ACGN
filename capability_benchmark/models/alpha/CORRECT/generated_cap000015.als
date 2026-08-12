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

pred cap000015 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv9 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchA))) }
pred cap000015c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv9 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap000015 { cap000015 iff cap000015c }
check CapBenchEquivalent_cap000015 for 4
