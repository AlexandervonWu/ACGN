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

pred cap005139 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv7 and ((no CapBenchB or some CapBenchB) and no CapBenchA)) and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
pred cap005139c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) or (not (inv7 and ((no CapBenchB or some CapBenchB) and no CapBenchA)))) }
assert CapBenchEquivalent_cap005139 { cap005139 iff cap005139c }
check CapBenchEquivalent_cap005139 for 4
