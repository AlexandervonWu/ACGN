open util/ordering[Grade]

sig Person {
	teaches : set Course,
	enrolled : set Course,
	projects : set Project
}

sig Professor,Student in Person {}

sig Course {
	projects : set Project,
	grades : Person -> Grade
}

sig Project {}

sig Grade {}

pred inv9 {
all t1,t2:Professor, c:t1.teaches | t1 != t2 and c in t2.teaches =>  
  		not some c2:Course | (c2 in t1.enrolled and c2 in t2.teaches) or (c2 in t2.enrolled and c2 in t1.teaches)
}

pred inv9c {
	all p : Person | no (p.teaches.~teaches - p) & p.teaches.~enrolled
}

check correct { inv9 <=> inv9c}
pred under { inv9 and !inv9c}
pred over { !inv9 and inv9c}
run over 
run under 

