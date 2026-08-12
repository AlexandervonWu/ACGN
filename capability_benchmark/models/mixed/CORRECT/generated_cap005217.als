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
all w:Workstation | lone w.succ
one w:Workstation | w.^succ = Workstation - w 
no end.succ
no succ.begin
begin.^succ = Workstation - begin
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

pred cap005217 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv9 and ((some CapBenchB or no CapBenchB) or no CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005217c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv9 and ((some CapBenchB or no CapBenchB) or no CapBenchB)))) }
assert CapBenchEquivalent_cap005217 { cap005217 iff cap005217c }
check CapBenchEquivalent_cap005217 for 4
