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

pred cap004625 { not ((inv6 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) and ((no CapBenchA and some capBenchS) and some capBenchR)) }
pred cap004625c { ((not ((no CapBenchA and some capBenchS) and some capBenchR)) or (not (inv6 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap004625 { cap004625 iff cap004625c }
check CapBenchEquivalent_cap004625 for 4
