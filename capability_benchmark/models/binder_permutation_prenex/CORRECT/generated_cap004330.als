sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv7 {
all t:Track | no t & t.(^succs)
}

pred inv7c {
	no t : Track | t in t.^succs
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004330 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv7 and ((no CapBenchA and some CapBenchB) and some capBenchS))) }
pred cap004330c { some a, b: CapBenchA | (b->a in capBenchR and (inv7 and ((no CapBenchA and some CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap004330 { cap004330 iff cap004330c }
check CapBenchEquivalent_cap004330 for 4
