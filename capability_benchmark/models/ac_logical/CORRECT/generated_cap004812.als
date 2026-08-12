sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv1 {
trans in State -> some Event -> State
}

pred inv1c {
	all s:State | some s.trans
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004812 { not ((inv1 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) and ((some capBenchS or some capBenchR) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap004812c { ((not ((some capBenchS or some capBenchR) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv1 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchR)))) }
assert CapBenchEquivalent_cap004812 { cap004812 iff cap004812c }
check CapBenchEquivalent_cap004812 for 4
