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

pred cap001801 { ((all x: CapBenchA | x->x in capBenchR) or (inv7 and ((some capBenchS or some capBenchS) or some capBenchR))) }
pred cap001801c { (all x: CapBenchA | (x->x in capBenchR or (inv7 and ((some capBenchS or some capBenchS) or some capBenchR)))) }
assert CapBenchEquivalent_cap001801 { cap001801 iff cap001801c }
check CapBenchEquivalent_cap001801 for 4
