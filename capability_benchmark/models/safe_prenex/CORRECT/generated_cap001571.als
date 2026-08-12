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

pred cap001571 { ((all x: CapBenchA | x->x in capBenchR) or (inv6 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchB))) }
pred cap001571c { (all x: CapBenchA | (x->x in capBenchR or (inv6 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchB)))) }
assert CapBenchEquivalent_cap001571 { cap001571 iff cap001571c }
check CapBenchEquivalent_cap001571 for 4
