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

pred cap002836 { not always ((inv7 and ((some CapBenchA and no CapBenchA) or some capBenchS))) }
pred cap002836c { eventually (not (inv7 and ((some CapBenchA and no CapBenchA) or some capBenchS))) }
assert CapBenchEquivalent_cap002836 { cap002836 iff cap002836c }
check CapBenchEquivalent_cap002836 for 4
