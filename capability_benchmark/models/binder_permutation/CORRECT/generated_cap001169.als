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

pred cap001169 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv9 and ((some CapBenchB or some capBenchS) or no CapBenchA))) }
pred cap001169c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv9 and ((some CapBenchB or some capBenchS) or no CapBenchA))) }
assert CapBenchEquivalent_cap001169 { cap001169 iff cap001169c }
check CapBenchEquivalent_cap001169 for 4
