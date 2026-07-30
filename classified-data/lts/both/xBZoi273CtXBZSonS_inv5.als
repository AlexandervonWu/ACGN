sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv5 {
some e:Event | all disj s1,s2:State | e in ~(Init.trans)[s1] implies e in ~(Init.trans)[s2]
}

pred inv5c {
	all s1,s2:State | s1.trans.State = s2.trans.State
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 

