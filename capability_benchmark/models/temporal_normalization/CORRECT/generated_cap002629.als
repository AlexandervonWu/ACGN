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

pred cap002629 { not once ((inv3 and ((some CapBenchB or some CapBenchA) or no CapBenchA))) }
pred cap002629c { historically (not (inv3 and ((some CapBenchB or some CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap002629 { cap002629 iff cap002629c }
check CapBenchEquivalent_cap002629 for 4
