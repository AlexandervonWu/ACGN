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
all w: Workstation | w not in w.^succ
all w, wb : Workstation | (wb in begin and w != wb) implies w in wb.^(succ)
all w : Workstation | w not in end implies one w.succ
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

pred cap001628 { ((some x: CapBenchA | x->x in capBenchR) and (inv9 and ((some CapBenchA and some CapBenchA) or no CapBenchA))) }
pred cap001628c { (some x: CapBenchA | (x->x in capBenchR and (inv9 and ((some CapBenchA and some CapBenchA) or no CapBenchA)))) }
assert CapBenchEquivalent_cap001628 { cap001628 iff cap001628c }
check CapBenchEquivalent_cap001628 for 4
