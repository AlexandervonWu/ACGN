module alloy4fun_augmented_coursesNew_inv5
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

pred inv5_oracle[] {
all p : Project | some (Person <: projects).p
	all p : Project | (Person <: projects).p in Student
}

pred inv5_correct_0[] {
all p : Project, s : Person | s in projects.p implies s in Student 
  	all p : Project | some s : Person | s in projects.p
}

pred inv5_correct_1[] {
all p: Person - Student | no p.projects
  all p: Project | some s: Student | p in s.projects
}

pred inv5_correct_2[] {
all proj : Project | proj in Person.projects
    all proj : Project, p:Person | proj in p.projects implies p in Student
}

pred inv5_correct_3[] {
all p:Person | all po:Project | p->po in projects implies p in Student
    all pr:Project | some s:Student | s->pr in projects
}

pred inv5_correct_4[] {
all p : Person | p in projects.Project => p in Student
  	all p : Project | some p1 : Person | p1 in projects.p
}

pred inv5_correct_5[] {
all p : Person | some p.projects implies p in Student
  	all proj : Project | proj in Person.projects
}

pred inv5_correct_6[] {
(all x: Person | all p: Project | p in x.projects => x in Student) && (all j: Project | some z: Person | z in projects.j)
}

pred inv5_correct_7[] {
all p : Person - Student | no p.projects 
  all p: Project | p in Person.projects
}

pred inv5_correct_8[] {
all x : Project | all y : Person | y in projects.x implies y in Student
  all x : Project | some y : Person | y in projects.x
}

pred inv5_correct_9[] {
all p:Project | projects.p & Person in Student
  all p:Project | some projects.p & Person
}

pred inv5_correct_10[] {
(all p:Person | all pr:Project | pr in p.projects implies p in Student)
    and
    (all pr:Project | some p:Person | pr in p.projects)
}

pred inv5_correct_11[] {
all p : Project, s : Person | p in s.projects implies s in Student
  	all p : Project | some s : Student | s in projects.p
}

pred inv5_correct_12[] {
all p1 : Project | some st1 : Student | st1->p1 in projects
  	all p2 : Project | all p : Person | p->p2 in projects implies p in Student
}

pred inv5_correct_13[] {
all x: Person - Student | no x.projects
  all p: Project | (some s: Student | p in s.projects)
}

pred inv5_correct_14[] {
all p: Person | p not in Student implies no p.projects
  all p: Project | (some s: Student | p in s.projects)
}

pred inv5_correct_15[] {
all x : Project | all y : Person | x in y.projects implies y in Student
  all x : Project | some y : Person | x in y.projects
}

pred inv5_correct_16[] {
all p : Person, x:Project | #p.projects >0 => p in Student 
  all p:Project | #(projects.p & Person)> 0
}

pred inv5_correct_17[] {
all p:Person-Student | no p.projects
	all p:Project | p in Student.projects
}

pred inv5_correct_18[] {
all p : Project | Person:>projects.p in Student and #Student:>projects.p >=1
}

pred inv5_correct_19[] {
all p : Person | some p.projects implies p in Student
  	all p : Project | some s : Student | p in s.projects
}

pred inv5_correct_20[] {
all p: Project | some (Person<:projects).p
	all p: Project, s: Person | s in projects.p implies s in Student
}

pred inv5_correct_21[] {
(all pro : Project | some s: Student | s->pro in projects)
  (all p2 : Project | all pr2 : Person   | pr2->p2 in projects implies pr2 in Student)
}

pred inv5_correct_22[] {
all p:Person | all pr:Project | p->pr in projects implies p in Student
  all pr:Project | some s:Student | s->pr in projects
}

pred inv5_correct_23[] {
all p1 : Project | some pr1 : Student | pr1->p1 in projects
  	all p2 : Project | all pr2 : Person   | pr2->p2 in projects implies pr2 in Student
}

pred inv5_correct_24[] {
all p:Project | some (Person <: projects).p
	all p:Project, x:Person | x in (Person <: projects).p implies x in Student
}

pred inv5_correct_25[] {
all s : Person, p : Project | (p in s.projects implies s in Student)
    all p : Project | some s : Student | s in projects.p
}

pred inv5_correct_26[] {
all x:Person | #(x.projects)>0 implies x in Student
  all x:Project | some y:Person | x in y.projects
}

pred inv5_correct_27[] {
Person :> projects.Project in Student
  	all p: Project | some Person :> projects.p
}

pred inv5_correct_28[] {
no (Person-Student).projects
  	Project in Student.projects
}

pred inv5_correct_29[] {
all x:Person | x not in Student implies #(x.projects)=0
  	all x:Project | some y:Person | x in y.projects
}

pred inv5_correct_30[] {
all p:Project, x:Person| x->p in projects implies x in Student
  all p:Project| some x:Student| x->p in projects
}

pred inv5_correct_31[] {
all p : Person-Student | no p.projects
  	all pr : Project | some s : Student | pr in s.projects
}

pred inv5_correct_32[] {
all p : Person, ps : Project | ps in p.projects implies p in Student
  	all p : Project | some person : Person | p in person.projects
}

pred inv5_correct_33[] {
all p : Person - Student | no p.projects 
    all pr : Project | some som : Person | pr in som.projects
}

pred inv5_correct_34[] {
(Person<: projects) in Student some -> set Project
}

pred inv5_correct_35[] {
all p:Project | some student:Person | p in student.projects && (all x:Person - Student | no x.projects)
}

pred inv5_correct_36[] {
all p : Person, pr : Project | pr in p.projects implies p in Student
  	all pr : Project | some p : Person | pr in p.projects
}

pred inv5_correct_37[] {
all p : Person, pr : Project | p not in Student implies pr not in p.projects
  	all pr: Project | some s : Student | pr in s.projects
}

pred inv5_correct_38[] {
all x : Person - Student | no x.projects
  
	
  
	all p : Project | (some pp : Person | p in pp.projects)
}

pred inv5_correct_39[] {
all x:Person | some x.projects implies x in Student
  	all x:Project | some Person <: projects.x
}

pred inv5_correct_40[] {
all s : Person - Student| no s.projects
	all p : Project | some s : Student | p in s.projects
}

pred inv5_correct_41[] {
all p: Person | some p.projects implies p in Student
	all proj: Project | some p: Person | p->proj in projects
}

pred inv5_correct_42[] {
all p : Person | #(p.projects)>0 implies p in Student
  	all proj : Project | some p : Person | proj in p.projects
}

pred inv5_correct_43[] {
all p: Person | some p.projects implies p in Student
  
  	all p: Project | some (Person<:projects).p
}

pred inv5_correct_44[] {
all p:Project | projects.p <: Person in Student
  all p:Project | some projects.p <: Person
}

pred inv5_correct_45[] {
all s : Person | all p : Project |  (p in s.projects) implies (s in Student) 
  	all  p : Project | some s : Person | s in projects.p
}

pred inv5_correct_46[] {
all p : Project | Person <: projects.p in Student
	all p : Project | some Person <: projects.p
}

pred inv5_correct_47[] {
all p : Person | (p not in Student) implies (p.projects=none)
    no p : Project | p.~(Person <: projects)=none
}

pred inv5_correct_48[] {
all p : Project | all p1 : Person | p in p1.projects implies p1 in Student
  	all p : Project | #(projects.p & Student) > 0
}

pred inv5_correct_49[] {
all p : Person - Student | no p.projects
  all a : Project | some s : Student | a in s.projects
}

pred inv5_correct_50[] {
all p : Person, pr : Project | p not in Student implies pr not in p.projects
  	all pr: Project | some s : Person | pr in s.projects
}

pred inv5_correct_51[] {
all p : Project | some Person <: projects.p and Person <: projects.p in Student
}

pred inv5_correct_52[] {
all p1 : Project | some s: Student  | s->p1 in projects
  	all p2 : Project | all  p: Person   | p->p2 in projects => p in Student
}

pred inv5_correct_53[] {
all ps : Project | some p1 : Person | ps in p1.projects
  all ps : Project | all p1 : Person | ps in p1.projects implies p1 in Student
}

pred inv5_correct_54[] {
(all per : Person | #per.projects > 0 implies per in Student)
	all p : Project | some per2 : Person | p in per2.projects
}

pred inv5_correct_55[] {
all p: Project | p in Student.projects and p not in (Person - Student).projects
}

pred inv5_correct_56[] {
all p : Person | some p.projects implies p in Student
  	all pr : Project | some Student.projects & pr
}

pred inv5_correct_57[] {
all project : Project | some student : Student | student->project in projects
  	all professor : Person - Student | no professor.projects
}

pred inv5_correct_58[] {
all x:Person-Student | no x.projects
  		all x:Project |some u:Student | x in u.projects
}

pred inv5_correct_59[] {
all per:Person | all po:Project | po in per.projects implies per in Student
    all pro:Project | some p:Person | pro in p.projects
}

pred inv5_correct_60[] {
all p : Person - Student | no p.projects
  all a : Project | some s : Student | s in projects.a
}

pred inv5_correct_61[] {
all x: Person | (some x.projects implies x in Student)
  all x: Project | some p: Person | p->x in projects
}

pred inv5_correct_62[] {
all p : Person - Student | no p.projects
    all p1 : Project | (some s : Student | p1 in s.projects)
}

pred inv5_correct_63[] {
all p : Project | all s : (Person<:projects).p | s in Student
  	all p : Project | some (Person<:projects).p
}

pred inv5_correct_64[] {
all p: Person - Student | no p.projects
    all p: Project | some s: Person | p in s.projects
}

pred inv5_correct_65[] {
all p : Person | some p.projects implies p in Student
  	all proj : Project | proj in Student.projects
}

pred inv5_correct_66[] {
all p:Person-Student | no p.projects
  all proj:Project | some s:Student | proj in s.projects
}

pred inv5_correct_67[] {
all a:Project| some c:Student | a in c.projects
  all a: Person-Student | no a.projects
}

pred inv5_correct_68[] {
all p : Project | some per: Person | per in projects.p and
    all s: Person | s in projects.p implies s in Student
}

pred inv5_correct_69[] {
all p : Project | Person <: projects.p in Student and some Person <: projects.p
}

pred inv5_correct_70[] {
all p:Person-Student | no p.projects 
  	all p:Project | some pe:Person | p in pe.projects
}

pred inv5_correct_71[] {
all x : Project | some Person <: projects.x && Person <: projects.x in Student
}

pred inv5_correct_72[] {
all p:Person| #p.projects >=1 implies p in Student 
  	all p:Project| some s:Student| p in s.projects
}

pred inv5_correct_73[] {
Person.projects - (Person - Student).projects = Project
}

pred inv5_correct_74[] {
all p : Person | all proj : Project | #(p.projects)>0 implies p in Student
  	all proj : Project | some p : Person | proj in p.projects
}

pred inv5_correct_75[] {
all p : Project | some person : Person | p in person.projects
  	all p : Project, person : Person | p in person.projects => person in Student
}

pred inv5_correct_76[] {
all x: Person, p : Project | p in x.projects => x in Student
  all p: Project | (some s: Student | p in s.projects)
}

pred inv5_correct_77[] {
all p : Person | some p.projects implies p in Student
  	all p : Project | some s : Person | p in s.projects
}

pred inv5_correct_78[] {
(((Person :> ((Person <: projects) . Project)) in Student) && (all ref0:(one Project)|(some (Person :> ((Person <: projects) . ref0)))))
}

pred inv5_correct_79[] {
(all p : Project | all per :Person -Student | no per.projects)
  	and
  	(all p : Project | some pe: Person | p in pe.projects)
}

pred inv5_correct_80[] {
(Person-Student).projects = none
  	 Project in Student.projects
}

pred inv5_correct_81[] {
all p : Project |
  		some s : Student |
  			p in s.projects
  	
  	no (Person - Student).projects
}

pred inv5_correct_82[] {
all p : Project, s : Person | s in projects.p implies s in Student 
  	all p : Project | some s : Person | s in projects.p and s in Student
}

pred inv5_correct_83[] {
all p:Person| some p.projects => p in Student
  
	
	all p:Project| some projects.p & Person
}

pred inv5_correct_84[] {
all x : Person - Student | no x.projects
  	all p : Project | some x : Student | p in x.projects
}

pred inv5_correct_85[] {
all p : Person | some p.projects implies p in Student
  	all proj : Project | proj in Person.projects
    all proj : Project | proj in Student.projects
}

pred inv5_correct_86[] {
all per:Person | all po:Project | po in per.projects implies per in Student
    all pro:Project | some s:Student | pro in s.projects
}

pred inv5_correct_87[] {
(all per :Person -Student | no per.projects)
  	and
  	(all p : Project | some pe: Person | p in pe.projects)
}

pred inv5_correct_88[] {
all p : Project, s : Person | s in projects.p implies s in Student 
  	all p : Project | some s : Student | s in projects.p
}

pred inv5_correct_89[] {
all p : Person | #(p.projects)> 0 implies p in Student
  all project : Project | some person : Person | project in person.projects
}

pred inv5_correct_90[] {
no (Person-Student).projects
	all p:Project | p in Person.projects
}

pred inv5_correct_91[] {
all x : Project | some Person <: projects.x
	all y : Person | (some y.projects :> Project) => y in Student
}

pred inv5_correct_92[] {
all p:Project | Person:>projects.p in Student and #Person:>projects.p>0
}

pred inv5_correct_93[] {
all p : Project | #((Person <: projects.p) - Student) = 0 and #((Person <: projects.p) & Student) > 0
}

pred inv5_correct_94[] {
all p:Project, x:Person| x->p in projects implies x in Student
  all p:Project| some x:Person| x->p in projects and x in Student
}

pred inv5_correct_95[] {
all p:Person - Student| no p.projects
	all pr:Project|some p:Person| pr in p.projects
}

pred inv5_correct_96[] {
all x:Person, p:Project| x->p in projects implies x in Student
  all p:Project| (some x:Student| x->p in projects)
}

pred inv5_correct_97[] {
all p: Person | #(p.projects)>0 implies p in Student
  	Project = Person.projects
}

pred inv5_correct_98[] {
all p: Project | all u: Person | p in u.projects implies u in Student
  	all p: Project | some u: Person | p in u.projects
}

pred inv5_correct_99[] {
all p:Project,c:Person| c in projects.p => c in Student
  all p:Project | some projects.p & Person
}

pred inv5_correct_100[] {
all p : Project | all  s : Person | p in s.projects implies s in Student
  	all p : Project | some s : Person | p in s.projects
}

pred inv5_correct_101[] {
all p : Person - Student | no p.projects
  	all p : Project | some per : Person | p in per.projects
}

pred inv5_correct_102[] {
all p: Person | some p.projects implies p in Student
	all p: Project | p in Person.projects
}

pred inv5_correct_103[] {
Person <: projects.Project in Student
    all p : Project | some Person <: projects.p
}

pred inv5_correct_104[] {
all x:Person| all p:Project| x->p in projects implies x in Student
  
   all p:Project| (some x:Student | x->p in projects)
}

pred inv5_correct_105[] {
all p :Project | some s : Student | p in s.projects
  	all u : Person-Student | #u.projects=0
}

pred inv5_correct_106[] {
all p : Project | Person:>projects.p in Student and #Person:>projects.p >=1
}

