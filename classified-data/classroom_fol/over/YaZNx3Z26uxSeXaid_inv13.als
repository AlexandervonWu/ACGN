sig Person  {
	Tutors : set Person,
	Teaches : set Class
}
sig Group {}

sig Class  {
	Groups : Person -> Group
}

sig Teacher in Person  {}

sig Student in Person  {}

pred inv13 {
all p1, p2:Person | (isTutored [p1] implies p1 in Student and p1 not in Teacher) and (isTutor [p2] implies p2 in Teacher and p2 not in Student)
}

pred isTutored (p1:Person){
	some p2:Person | p2->p1 in Tutors
}

pred isTutor (p1:Person){
	some p2:Person | p1->p2 in Tutors
}

pred inv13c {
  Tutors in Teacher -> Student
}

check correct { inv13 <=> inv13c}
pred under { inv13 and !inv13c}
pred over { !inv13 and inv13c}
run over 
run under 

