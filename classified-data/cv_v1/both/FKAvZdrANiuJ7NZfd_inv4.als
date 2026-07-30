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
        all u:User, w1,w2:Work | (((w1.ids=w2.ids) and (w1 in u.profile) and (w2 in u.profile)) implies not ((w1 in u.visible)) and (w2 in u.visible))
}

pred inv4c {  
	all u : User, disj x,y : u.visible | x not in y.^(ids.~ids)
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 


