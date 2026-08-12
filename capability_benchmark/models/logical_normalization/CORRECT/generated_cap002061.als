sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv6 {
all e:Event | some s1,s2:State | s1->e->s2 in trans
}

pred inv6c {
	State.trans.State = Event
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002061 { not ((inv6 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) and ((no CapBenchA and some capBenchS) and no CapBenchB)) }
pred cap002061c { ((not (inv6 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA))) or (not ((no CapBenchA and some capBenchS) and no CapBenchB))) }
assert CapBenchEquivalent_cap002061 { cap002061 iff cap002061c }
check CapBenchEquivalent_cap002061 for 4
