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

pred cap005384 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv6 and ((some CapBenchA and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) and ((some capBenchS or some capBenchS) or some CapBenchA))) }
pred cap005384c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or some capBenchS) or some CapBenchA)) or (not (inv6 and ((some CapBenchA and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005384 { cap005384 iff cap005384c }
check CapBenchEquivalent_cap005384 for 4
