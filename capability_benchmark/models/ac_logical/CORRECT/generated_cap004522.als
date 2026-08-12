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

pred cap004522 { not ((inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchA)) and ((no CapBenchB or some CapBenchA) and no CapBenchB)) }
pred cap004522c { ((not ((no CapBenchB or some CapBenchA) and no CapBenchB)) or (not (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchA)))) }
assert CapBenchEquivalent_cap004522 { cap004522 iff cap004522c }
check CapBenchEquivalent_cap004522 for 4
