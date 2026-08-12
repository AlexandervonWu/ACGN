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

pred cap002516 { not (((inv7 and ((some CapBenchA and no CapBenchA) or some CapBenchA))) until (((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
pred cap002516c { ((not (inv7 and ((some CapBenchA and no CapBenchA) or some CapBenchA))) releases (not ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap002516 { cap002516 iff cap002516c }
check CapBenchEquivalent_cap002516 for 4
