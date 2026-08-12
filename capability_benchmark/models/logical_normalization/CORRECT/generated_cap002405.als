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

pred cap002405 { ((inv9 and ((some capBenchS or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) iff ((no CapBenchA and some CapBenchA) and some CapBenchB)) }
pred cap002405c { (((not (inv9 and ((some capBenchS or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) or ((no CapBenchA and some CapBenchA) and some CapBenchB)) and ((not ((no CapBenchA and some CapBenchA) and some CapBenchB)) or (inv9 and ((some capBenchS or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap002405 { cap002405 iff cap002405c }
check CapBenchEquivalent_cap002405 for 4
