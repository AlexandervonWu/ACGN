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

pred cap002063 { ((inv7 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchA)) iff ((some capBenchR and some capBenchS) or no CapBenchB)) }
pred cap002063c { (((not (inv7 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchA))) or ((some capBenchR and some capBenchS) or no CapBenchB)) and ((not ((some capBenchR and some capBenchS) or no CapBenchB)) or (inv7 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchA)))) }
assert CapBenchEquivalent_cap002063 { cap002063 iff cap002063c }
check CapBenchEquivalent_cap002063 for 4
