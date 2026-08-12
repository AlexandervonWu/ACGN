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

pred cap002890 { not always ((inv9 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap002890c { eventually (not (inv9 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002890 { cap002890 iff cap002890c }
check CapBenchEquivalent_cap002890 for 4
