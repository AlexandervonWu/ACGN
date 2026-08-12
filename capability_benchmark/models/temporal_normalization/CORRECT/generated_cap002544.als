sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv1 {
all s: State | some s.trans
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

pred cap002544 { not historically ((inv1 and ((some capBenchR and some capBenchS) or some CapBenchA))) }
pred cap002544c { once (not (inv1 and ((some capBenchR and some capBenchS) or some CapBenchA))) }
assert CapBenchEquivalent_cap002544 { cap002544 iff cap002544c }
check CapBenchEquivalent_cap002544 for 4
