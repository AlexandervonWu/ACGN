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

pred cap002404 { ((inv9 and ((some capBenchR and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) implies ((some CapBenchB or some CapBenchA) or some CapBenchB)) }
pred cap002404c { ((not (inv9 and ((some capBenchR and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) or ((some CapBenchB or some CapBenchA) or some CapBenchB)) }
assert CapBenchEquivalent_cap002404 { cap002404 iff cap002404c }
check CapBenchEquivalent_cap002404 for 4
