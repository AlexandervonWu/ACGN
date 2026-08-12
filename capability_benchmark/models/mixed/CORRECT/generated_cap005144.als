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
all w : Workstation | w != begin => one succ.w
all w : Workstation | w != end => one w.succ
all w : Workstation | w not in w.^succ
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

pred cap005144 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv9 and ((some CapBenchA and no CapBenchA) or no CapBenchA)) and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
pred cap005144c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) or (not (inv9 and ((some CapBenchA and no CapBenchA) or no CapBenchA)))) }
assert CapBenchEquivalent_cap005144 { cap005144 iff cap005144c }
check CapBenchEquivalent_cap005144 for 4
