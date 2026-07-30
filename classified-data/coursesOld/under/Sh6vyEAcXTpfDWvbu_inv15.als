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

pred inv15 {
all s1, s2: Student | all c : Course | some g1,g2 : Grade | working2gether[s1,s2,c] and (s1->g1)+(s2->g2) in c.grades implies consecGrades[g1,g2]
}

pred working2gether[s1,s2:Student,c:Course]{
	all p : c.projects | s1!=s2 and c in s1.enrolled&s2.enrolled and p in s1.projects+s2.projects
}

pred consecGrades[g1,g2:Grade]{
	g1!=g2 and g1 = prev[g2]  
}

pred inv15c {
	all c : Course, p : c.projects, disj x,y : (Person <: projects).p | some c.grades[x] and some c.grades[y] implies c.grades[x] in c.grades[y].(prev+iden+next)
}

check correct { inv15 <=> inv15c}
pred under { inv15 and !inv15c}
pred over { !inv15 and inv15c}
run over 
run under 

