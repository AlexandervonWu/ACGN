sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv7 {
all disj t1,t2:Track | (t1 not in t1.succs and t2 not in t2.succs) and (t2 in t1.succs => t1 not in t2.succs and t1.succs not in t2.succs and t2.succs not in t1.succs)
}

pred inv7c {
	no t : Track | t in t.^succs
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 

