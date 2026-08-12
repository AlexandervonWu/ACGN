sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv3 {
all s,s1,s2:State,e:Event | s->e->s1 in trans and s->e->s2 in trans implies s1=s2
}

pred inv3c {
	all s : State, e : Event | lone e.(s.trans)
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004306 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv3 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR))) }
pred cap004306c { some a, b: CapBenchA | (b->a in capBenchR and (inv3 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR))) }
assert CapBenchEquivalent_cap004306 { cap004306 iff cap004306c }
check CapBenchEquivalent_cap004306 for 4
