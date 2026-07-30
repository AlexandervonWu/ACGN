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
pred inv8 {
all d,ws : univ | ws in Workstation and d in Dangerous and d->ws in workstation implies all w : Worker | ws->w in workers implies w not in Human
}

pred inv8c {
	all c : Component & Dangerous | no c.workstation.workers & Human
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 

