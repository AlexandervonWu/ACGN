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

pred cap000823 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv9 and ((no CapBenchB or some CapBenchA) and some capBenchS))) }
pred cap000823c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv9 and ((no CapBenchB or some CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap000823 { cap000823 iff cap000823c }
check CapBenchEquivalent_cap000823 for 4
