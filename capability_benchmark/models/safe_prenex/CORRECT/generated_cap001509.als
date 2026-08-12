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

pred cap001509 { ((all x: CapBenchA | x->x in capBenchR) or (inv6 and ((some CapBenchB or some CapBenchB) or some CapBenchA))) }
pred cap001509c { (all x: CapBenchA | (x->x in capBenchR or (inv6 and ((some CapBenchB or some CapBenchB) or some CapBenchA)))) }
assert CapBenchEquivalent_cap001509 { cap001509 iff cap001509c }
check CapBenchEquivalent_cap001509 for 4
