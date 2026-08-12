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

pred cap002003 { ((inv7 and ((no CapBenchB or some CapBenchA) and some CapBenchA)) iff ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) }
pred cap002003c { (((not (inv7 and ((no CapBenchB or some CapBenchA) and some CapBenchA))) or ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) and ((not ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) or (inv7 and ((no CapBenchB or some CapBenchA) and some CapBenchA)))) }
assert CapBenchEquivalent_cap002003 { cap002003 iff cap002003c }
check CapBenchEquivalent_cap002003 for 4
