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
pred inv7 {
all c: Component | all x: c.parts | x in Dangerous => c in Dangerous
}

pred inv7c {
	all c : Component | some c.parts & Dangerous implies c in Dangerous
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000406 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap000406c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000406 { cap000406 iff cap000406c }
check CapBenchEquivalent_cap000406 for 4
