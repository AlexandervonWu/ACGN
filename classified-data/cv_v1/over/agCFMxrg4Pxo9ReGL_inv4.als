abstract sig Source {}
sig User extends Source {
    profile : set Work,
    visible : set Work
}
sig Institution extends Source {}

sig Id {}
sig Work {
    ids : some Id,
    source : one Source
}

pred inv4 {
    all u:User , w:Work, w1:Work | (w in u.visible and w1 in u.visible) implies w != w1
}

pred inv4c {  
	all u : User, disj x,y : u.visible | x not in y.^(ids.~ids)
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 


