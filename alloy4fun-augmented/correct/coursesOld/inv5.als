module alloy4fun_augmented_coursesOld_inv5
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
(Person<:projects).Project in Student
  	all pr:Project | some p:Person | p->pr in Person<:projects
}

pred inv5_correct_1[] {
Person <: projects in Student some -> Project
}

pred inv5_correct_2[] {
(Person <: projects).Project in Student
  	Person.projects = Project
}

pred inv5_correct_3[] {
all p : Project | some (Person :> projects.p)
	all p: Project | (Person :> projects.p) in Student
}

pred inv5_correct_4[] {
no (Person-Student).projects
  	all p:Project | some Person <: (projects).p
}

pred inv5_correct_5[] {
all p : Project | some (Person :> projects.p)
  
    
     (Person :> projects.Project) in Student
}

pred inv5_correct_6[] {
no (Person - Student).projects
  all p : Project | some s : Student | p in s.projects
}

pred inv5_correct_7[] {
all per:Person-Student, p:Project | p not in per.projects
  	all p:Project | some ps:Student | p in ps.projects
}

pred inv5_correct_8[] {
all p:Project | some s:Student | s->p in projects
	all s:Person, p:Project | s->p in projects implies s in Student
}

pred inv5_correct_9[] {
(all p:Person, pj:Project | p -> pj in projects implies p in Student) and (all pj:Project | some per:Person | per -> pj in projects)
}

pred inv5_correct_10[] {
no (Person-Student) & projects.Project
	
  	
  	all p:Project | some pe:Person | pe in projects.p
}

pred inv5_correct_11[] {
all p:Project| Person <: projects.p != none and Person <: projects.p in Student
}

pred inv5_correct_12[] {
all p : Person | some p.projects => p in Student
  	all p : Project | some projects.p :> Person
}

pred inv5_correct_13[] {
(all p: Project, p1: Person | p in p1.projects implies p1 in Student) and (all p2: Project | some p3: Student | p2 in p3.projects)
}

pred inv5_correct_14[] {
all p:Project | some s:Student | s->p in projects
  	all p:Project, s:Person | s->p in projects implies s in Student
}

pred inv5_correct_15[] {
all p : Project | some Person.projects & p
  all p : Person | some p.projects implies p in Student
}

pred inv5_correct_16[] {
all x:Person-Student, y:Project | x->y not in projects
  all x:Project | some y:Person | y->x in projects
}

pred inv5_correct_17[] {
no (Person - Student).projects 
  	all p: Project | some s : Student | s->p in projects
}

pred inv5_correct_18[] {
no (Person-Student).projects  
    all p: Project | some x: Student | p in x.projects
}

pred inv5_correct_19[] {
all p : Person - Student | p.projects = none
  	all p : Project | p in Student.projects
}

pred inv5_correct_20[] {
all p : Person - Student | no p.projects
	all p : Project | p in Student.projects
}

pred inv5_correct_21[] {
all pr : Project | Person <:projects.pr in Student
  	all pr: Project | some Person <:projects.pr
}

pred inv5_correct_22[] {
no (Person-Student) & projects.Project
	
  	all p:Project | some (Person <: projects.p)
}

pred inv5_correct_23[] {
all p: Person, proj: Project | p->proj in (Person <: projects) implies p in Student
  	all proj: Project | some (Person <: projects).proj
}

pred inv5_correct_24[] {
all p:Person, pr:Project | p->pr in Person<:projects => p in Student
  	all pr:Project | some p:Person | p->pr in Person<:projects
}

pred inv5_correct_25[] {
all p: Project | some (Person<:projects).p and (Person<:projects).p in Student
}

pred inv5_correct_26[] {
all p:Project, ps:Person | ps in (Person <: projects).p implies ps in Student
  	all p:Project | some (Person <: projects).p
}

pred inv5_correct_27[] {
all p: Project | some (Person<:projects).p
  no (Person-Student).projects
}

pred inv5_correct_28[] {
all p:Project | Person<:projects.p in Student
  all p:Project | some Person<:projects.p
}

pred inv5_correct_29[] {
all p:Project, pe:Person | p in pe.projects implies pe in Student
  all p:Project | some s:Student | p in s.projects
}

pred inv5_correct_30[] {
Person<:projects.Project in Student
  	all p : Project | some Person<:projects.p
}

pred inv5_correct_31[] {
(all p1 : Project | some pr1 : Student | pr1->p1 in projects)
  	(all p2 : Project | all pr2 : Person  | pr2->p2 in projects implies pr2 in Student)
}

pred inv5_correct_32[] {
no (Person - Student).projects 
  	all p: Project | some person: Person | person->p in projects
}

pred inv5_correct_33[] {
all p: Project | all x: Person | p in x.projects implies x in Student
  	all p: Project | p in Student.projects
}

pred inv5_correct_34[] {
all proj : Project | (all person1 : Person | person1 not in Student implies person1->proj not in Person<:projects) and (some person2 : Person | person2->proj in Person<:projects)
}

pred inv5_correct_35[] {
all p:Project | some s:Student | p in s.projects
  all p:Person | all pr:Project | pr in p.projects implies p in Student
}

pred inv5_correct_36[] {
all p : Project | no ((Person<:projects).p & (Person - Student)) and some (Person<:projects).p
}

pred inv5_correct_37[] {
all p : Project | (Person<:projects.p) in Student and some (Person<:projects.p)
}

pred inv5_correct_38[] {
all p : Person | p not in Student implies p not in Person<:projects.Project
  	all p : Project | some Person<:projects.p
}

pred inv5_correct_39[] {
all p : Project, b : Person | p in b.projects => b in Student
  	all p : Project | some b : Person | p in b.projects
}

pred inv5_correct_40[] {
all p : Project | p in Person.projects
  	all p : Project, u : Person | p in u.projects implies u in Student
}

pred inv5_correct_41[] {
all p:Project | some s:Student | s -> p in projects
    all project:Project, person:Person | person -> project in projects implies person in Student
}

pred inv5_correct_42[] {
all p:Project, p1: Person | p1 in projects.p implies p1 in Student
    all p : Project | p in Person.projects
}

pred inv5_correct_43[] {
all p:Project, p1: Person | p1 in projects.p implies p1 in Student
	

    all p: Project |some p1: Person| p1 in projects.p
}

pred inv5_correct_44[] {
Person <: projects.Project in Student and Project in Person.projects
}

pred inv5_correct_45[] {
all p: Project | (Person<:projects).p in Student and some (Person<:projects).p
}

pred inv5_correct_46[] {
Project in Person.projects
    no (Person - Student).projects
}

pred inv5_correct_47[] {
all project : Project , person : Person | person->project in projects implies person in Student
  all p : Project | some person : Person | person -> p  in projects
}

pred inv5_correct_48[] {
no (Person - Student).projects
  	Project in Student.projects
}

pred inv5_correct_49[] {
all p : Project | some s : Student | p in s.projects
  	no (Person - Student).projects
}

pred inv5_correct_50[] {
all p: Person, o: Project | o in p.projects implies p in Student 
  	all l: Project | some p:Person | p->l in projects
}

pred inv5_correct_51[] {
all p : Project | some s : Student | p in s.projects 
  all p : Project | all pe : Person | p in pe.projects implies pe in Student
}

pred inv5_correct_52[] {
all p:Person, pr:Project | p->pr in projects implies p in Student
  	all pro:Project | some pe:Person | pe->pro in projects
}

pred inv5_correct_53[] {
all x : univ | x in Project implies some y : Student | y->x in Person<:projects
	all p : Project | all s : Person | s->p in Person<:projects implies s in Student
}

pred inv5_correct_54[] {
(all per:Person, proj:Project | per->proj in projects implies per in Student) and (all proj:Project | some per:Person | per->proj in projects)
}

pred inv5_correct_55[] {
(Person<:projects).Project in Student
  	Person<:projects in Person some -> Project
}

pred inv5_correct_56[] {
all pro : Project, per : Person | per->pro in projects => per in Student
	
	all pro : Project | some per : Person | per->pro in projects
}

pred inv5_correct_57[] {
all x : Project | (projects).x <: Person in Student
  	all x : Project | some (projects).x <: Person
}

pred inv5_correct_58[] {
all p : Person | some p.projects implies p in Student
  	all pr : Project | some p : Person | pr in p.projects
}

pred inv5_correct_59[] {
all p : Project | some projects.p <: Person
	all p : Project | projects.p <: Person in Student
}

pred inv5_correct_60[] {
all p: Project | (Person <: projects.p)  in Student and some pe: Person | pe -> p in projects
}

pred inv5_correct_61[] {
all p : Project | all p2 : Person | p2->p in projects implies p2 in Student 
  all p : Project | some p2 : Person | p2->p in projects
}

pred inv5_correct_62[] {
all p : Project | p.~(Person <: projects) in Student
    
    all p : Project | some (Person <: projects).p
}

pred inv5_correct_63[] {
all p : Project | (Person <: p.~projects) in Student and some (Person <: p.~projects)
}

pred inv5_correct_64[] {
all p : Project | some s : Student | s->p in projects
  all p1 : Project | all p2 : Person | p2->p1 in projects implies p2 in Student
}

pred inv5_correct_65[] {
all x:Project, y:Person-Student | y->x not in projects
  all x:Project | some y:Student | y->x in projects
}

pred inv5_correct_66[] {
(all p : Person, proj1 : Project | p->proj1 in projects implies p in Student ) and (all proj : Project | some  s : Student | s->proj in projects)
}

pred inv5_correct_67[] {
all p : Project | some Person<:projects.p and Person<:projects.p in Student
}

pred inv5_correct_68[] {
all p : Project | some s : Student | s->p in projects
	all person : Person, p2 : Project | person->p2 in projects implies person in Student
}

pred inv5_correct_69[] {
all p : Project | p.~(Person <: projects) in Student
    
    all p : Project | some p.~(Person <: projects)
}

pred inv5_correct_70[] {
all p:Project | some (Person <: projects).p
	all p:Project, x:Person | x in (Person <: projects).p implies x in Student
}

pred inv5_correct_71[] {
Person.projects - (Person - Student).projects = Project
}

pred inv5_correct_72[] {
all p:Person | all pro:Project | p->pro in projects implies p in Student 
    all pro:Project | some p1:Person | p1->pro in projects
}

pred inv5_correct_73[] {
all p : Project | p.~(Person <: projects) in Student and some p.~(Person <: projects)
}

pred inv5_correct_74[] {
all p : Project | some s : Person | p in s.projects 
  	all p : Project | all s : Person | p in s.projects implies s in Student
}

pred inv5_correct_75[] {
all p : Project | some s : Student | s->p in projects and all per : Person | per->p in projects implies per in Student
}

pred inv5_correct_76[] {
all p : Project | all s : Person | s->p in Person<:projects implies s in Student
    all x : univ | x in Project implies some y : Student | y->x in Person<:projects
}

pred inv5_correct_77[] {
all p:Person | all po:Project | p->po in projects implies p in Student
    all pr:Project | some s:Student | s->pr in projects
}

pred inv5_correct_78[] {
all p : Project | some Person<:projects.p
  	all p : Project | Person<:projects.p in Student
}

pred inv5_correct_79[] {
all x : Project, y : Person | y->x in projects implies y in Student
  	all x : Project | some y : Student | y->x in projects
}

pred inv5_correct_80[] {
all x: Person - Student | no x.projects
    all p: Project | (some s: Student | p in s.projects)
}

pred inv5_correct_81[] {
all p : Project | all e : Person | e->p in projects implies e in Student
  	all p : Project | some e : Person | e->p in projects
}

pred inv5_correct_82[] {
all p : Person | some p.projects implies p in Student
    all p : Project | some Person<:projects.p
}

pred inv5_correct_83[] {
all p:Person , pr:Project|p->pr in projects implies p in Student
    all p:Project |some s:Student | s->p in projects
}

pred inv5_correct_84[] {
Person & projects.Project in Student
  all p : Project | some Student & projects.p
}

pred inv5_correct_85[] {
((Person<:projects).Project in Student) and (all p : Project | some s : Student | p in s.projects)
}

pred inv5_correct_86[] {
Person :> projects.Project in Student
  	all p: Project | some Person :> projects.p
}

pred inv5_correct_87[] {
(all p: Project, x: Person | x->p in projects implies x in Student) and (all p: Project | some s: Student | s->p in projects)
}

pred inv5_correct_88[] {
all p : Project | p in Person.projects
    no (Person - Student).projects
}

pred inv5_correct_89[] {
(Person <: projects) in Student some -> Project
  
  all p: Person, p1:Project | (p->p1 in projects => p in Student)
}

pred inv5_correct_90[] {
all p : Person-Student | p.projects = none
  	all p : Project | p in Person.projects
}

pred inv5_correct_91[] {
all p : Person - Student, pr : Project | pr not in p.projects
  	all pr : Project | some s : Student | pr in s.projects
}

pred inv5_correct_92[] {
all pr: Project, p : Person | no (p & Student) implies pr not in p.projects  
  
  all p: Project | some s : Student | p in s.projects
}

pred inv5_correct_93[] {
all p:Project | some Student<:projects.p
  
  all p:Project | Person<:projects.p in Student
  all p:Project | some Person<:projects.p
}

pred inv5_correct_94[] {
all p:Project | some s:Person | s->p in projects
	all s:Person, p:Project | s->p in projects implies s in Student
}

pred inv5_correct_95[] {
no (Person <: projects).Project - Student
  	all p : Project | some (Person <: projects).p
}

pred inv5_correct_96[] {
all pro: Project | #pro.~{Student <: projects} >= 1 and #pro.~{{Person-Student} <: projects} = 0
}

pred inv5_correct_97[] {
all pj: Project, p: Person | pj in p.projects implies p in Student
  all pj: Project | some p: Person | pj in p.projects
}

pred inv5_correct_98[] {
all p: Person | p in projects.Project implies p in Student 
  	all p: Project | some (Person<:projects).p
}

pred inv5_correct_99[] {
(all p:Person, pj:Project | p->pj in projects implies p in Student) and (all pj:Project | some p:Person | p->pj in projects)
}

pred inv5_correct_100[] {
(all p: Person, pr : Project | p -> pr in projects implies p in Student) and (all pr1 : Project | some s : Student | s -> pr1 in projects)
}

pred inv5_correct_101[] {
all p:Person | some p.projects implies p in Student
  	Project in Person.projects
}

pred inv5_correct_102[] {
(all p : Project | some per : Person | per->p in projects)
  	(all p : Project | all per : Person  | per->p in projects implies per in Student)
}

pred inv5_correct_103[] {
all p : Person |all pro : Project |pro in p.projects implies p in Student
  all pro : Project | some p : Person | pro in p.projects
}

pred inv5_correct_104[] {
(Person<:projects).Project in Student
    
    all y:Project| some (Person<:projects).y
}

pred inv5_correct_105[] {
all x : univ | x in Project implies some y : Student | y->x in Person<:projects
    all x, y : univ | x in Person and y in Project and x->y in Person<:projects implies x in Student
}

pred inv5_correct_106[] {
(all per:Person, proj:Project | per->proj in projects implies per in Student) and (all proj2:Project | some per:Person | per->proj2 in projects)
}

pred inv5_correct_107[] {
all p:Person,j:Project | p->j in projects implies p in Student
  	all j:Project | some p:Person | p->j in projects
}

pred inv5_correct_108[] {
no (Person-Student).projects
  	all p:Project | some a:Person | p in a.projects
}

pred inv5_correct_109[] {
all p : Project | some s : Student | p in s.projects
  	all pr : Project | all p : Person   | pr in p.projects implies p in Student
}

pred inv5_correct_110[] {
all proj : Project | some p : Person | proj in p.projects
	all proj : Project | all p : Person  | proj in p.projects implies p in Student
}

pred inv5_correct_111[] {
(all pj : Project | all p : Person | p->pj in projects implies p in Student)
	and
	(all pj : Project | some p : Person | p->pj in projects)
}

pred inv5_correct_112[] {
all pr:Project, p:Person | p in (Person <: projects).pr implies p in Student
    all pr:Project| some (Person <: projects).pr
}

pred inv5_correct_113[] {
all x : Person - Student | no x.projects
  	all x : Project | some y : Student | x in y.projects
}

pred inv5_correct_114[] {
all p1 : Project | some p2 : Student | p2->p1 in projects
  all p1 : Person | all p2 : Project | p1->p2 in projects implies p1 in Student
}

pred inv5_correct_115[] {
all pr:Project, p:Person | p->pr in projects implies p in Student
  	all p:Project | some s:Student | p in s.projects
}

pred inv5_correct_116[] {
Project.~(Person<:projects) in Student
  	all p : Project | some p.~(Person<:projects)
}

pred inv5_correct_117[] {
all p : Project | p in Student.projects
  	all p : Person - Student | p.projects = none
}

pred inv5_correct_118[] {
no (Person-Student) & (Person :> projects.Project)
  	all p : Project | some (Person :> projects.p)
}

pred inv5_correct_119[] {
all p: Project | all s: Person | s->p in projects implies s in Student
    all p: Project | some s: Person | s->p in projects
}

pred inv5_correct_120[] {
no (Person-Student).projects and all p: Project | p in Person.projects
}

pred inv5_correct_121[] {
all p : Person | some p.projects implies p in Student
  	all p : Project | p in Student.projects
}

pred inv5_correct_122[] {
all p: Person | some p.projects => p in Student
	
	all p: Project | some s: Person | p in s.projects
}

pred inv5_correct_123[] {
all p:Project | some projects.p & Person
  	
  
  	all p:Project | projects.p & Person in Student
}

pred inv5_correct_124[] {
all proj:Project | all p:Person | p->proj in projects implies p in Student
    all proj:Project | some p:Student | p->proj in projects
}

pred inv5_correct_125[] {
all p : Project | all s : Person | p in s.projects implies s in Student
  	all p : Project | p in Student.projects
}

pred inv5_correct_126[] {
all p:Project | some (Person <: projects).p
	all p:Project, x:Person |p in x.projects implies x in Student
}

pred inv5_correct_127[] {
all person : Person - Student | person.projects = none
  	all project: Project | project in Student.projects
}

pred inv5_correct_128[] {
all p: Person | p in projects.Project implies p in Student
  	all p: Project | some person: Person | person in projects.p
}

pred inv5_correct_129[] {
all p : Project | some projects & Student->p
  	all p : Person | some p.projects implies p in Student
}

pred inv5_correct_130[] {
all p: Project | some pe: Person | pe -> p in projects
  all pe: Person , p: Project | pe in Student or not(pe->p in projects)
}

pred inv5_correct_131[] {
all p : Project | (Person :> p.~projects) in Student and some (Person :> p.~projects)
}

pred inv5_correct_132[] {
all p: Person, tp: Project | tp in p.projects implies p in Student
  all tp: Project | some s: Student | tp in s.projects
}

pred inv5_correct_133[] {
(all a : Person, b : Project | b in a.projects implies a in Student) and (all d : Project | some c : Person | d in c.projects)
}

pred inv5_correct_134[] {
not some p:Person-Student | some proj:Project | p->proj in projects
  all proj:Project | some s:Student | s->proj in projects
}

pred inv5_correct_135[] {
all p: Person , pr : Project | p in Student or p->pr not in projects
  all pr: Project | some s:Student | s->pr in projects
}

pred inv5_correct_136[] {
#(Person-Student).projects = 0
  
	all p: Project | p in Student.projects
}

pred inv5_correct_137[] {
no (Person - Student).projects
  	all p : Project | some pe : Person | p in pe.projects
}

pred inv5_correct_138[] {
all p:Project | some projects.p & Person
  	all p:Project | some projects.p & Person implies projects.p & Person in Student
}

pred inv5_correct_139[] {
projects.Project <: Person in Student
    all p : Project | some projects.p <: Person
}

pred inv5_correct_140[] {
all p : Project | some projects & Person->p
  	all p : Person | some p.projects implies p in Student
}

pred inv5_correct_141[] {
no Project.~(Person<:projects) - Student
  	all p:Project | some s:Student | s in p.~(Person<:projects)
}

pred inv5_correct_142[] {
all s : Person | some s.projects implies s in Student
  all p : Project | some s : Person | p in s.projects
}

pred inv5_correct_143[] {
all s : Person,p : Project | p in s.projects implies s in Student
  all p:Project | some s:Person | p in s.projects
}

pred inv5_correct_144[] {
all p: Person, proj: Project | proj in p.projects implies p in Student
  	all proj: Project | some (Person <: projects).proj
}

pred inv5_correct_145[] {
(all p:Project | some s:Student | s->p in projects)
	(all p:Project | all per:Person | per->p in projects implies per in Student)
}

pred inv5_correct_146[] {
all pj: Project, p:Person | p in (Person <: projects).pj implies p in Student
  	all pj: Project | some (Person <: projects).pj
}

pred inv5_correct_147[] {
all p : Project | no (Person-Student)  & (Person<:projects.p) and some (Person<:projects.p)
}

pred inv5_correct_148[] {
all p:Project | (Person <: projects).p in Student
  	all p:Project |	some (Person <: projects).p
}

pred inv5_correct_149[] {
all p:Project | some (Person <: projects).p
	all p:Project, x:Person |some (Person <: projects).p and x in (Person <: projects).p implies x in Student
}

pred inv5_correct_150[] {
all p: Project | some s: Person | p in s.projects
  	all p: Person | some p.projects => p in Student
}

pred inv5_correct_151[] {
no (Person-Student) & (Person<:projects).Project
  
  
	
  	all proj:Project | some (Person<:projects).proj
}

pred inv5_correct_152[] {
no (Person-Student).projects
  	(this/Person <: projects) in Student some -> Project
}

pred inv5_correct_153[] {
(no (Person-Student).projects) and (Project in Person.projects)
}

