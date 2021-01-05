CREATE DATABASE Stagaire
USE Stagaire
----1-TABLE ETUDIANT------------------
CREATE TABLE Etudiant
(
Id_Etudiant varchar(10) ,
Nom_Etu varchar(20),
Prenom_Etu varchar(20),
Date_inscr date,
Date_naiss date
constraint pk1 primary key (Id_Etudiant)
)
alter table Etudiant
add constraint chk1 default (getdate()) for Date_inscr
alter table Etudiant
add constraint chk2 check(Date_naiss<getdate())

alter table Etudiant
add code_groupe varchar(6) foreign key references Groupe(code_groupe)
---1--TABLE MODULES------------------
CREATE TABLE Modules
(
Num_Module int,
Nom_Module varchar(20),
Masse_Horaire int
constraint pk2 primary key (Num_Module)
)
---3--TABLE NOTER------------------
CREATE TABLE Noter
(
Id_Etudiant varchar(10),
Num_Module int,
NoteCRR float,
NoteEFF float,
constraint fk1 foreign key (Id_Etudiant) references Etudiant(Id_Etudiant),
constraint fk2 foreign key (Num_Module) references Modules(Num_Module)
)
--------------4--TABLE Groupe-----------------
CREATE TABLE Groupe
(
code_groupe varchar(6) primary key,
nom_groupe varchar(50)
)



---------------5-insertion----------------

insert into Modules values 
(01,'Metier et formation',12),
(04,'bureautique',12),
(08,'bases de donnees',12),
(09,'Dev client serveur',12)

insert into Noter values
(1,01,13,14),
(2,04,19,18),
(3,08,18,19),
(4,09,18,19)

insert into Etudiant(Id_Etudiant,Nom_Etu,Prenom_Etu,Date_naiss,code_groupe) values
(1,'benakka','oussama','2001/02/04','TDI201'),
(2,'hamazaoui','bacaha','2000/01/07','TDI201'),
(3,'haha','hamza','2001/02/04','TDI202'),
(4,'baba','ahmed','2000/01/07','TDI101'),
(5,'gaga','noufel','2001/02/04','TDI202'),
(6,'nana','hamid','2000/01/07','TDI201'),
(7,'goka','amine','2001/02/04','TDI101'),
(8,'haza','jamal','2000/01/07','TDI102')

insert into Groupe values
('TDI101','Groupe 1�re ann�e TDI101'),
('TDI102','Groupe 1�re ann�e TDI102'),
('TDI201','Groupe 2�me ann�e TDI201'),
('TDI202','Groupe 2�me ann�e TDI202')

--------------------------PROBL�ME--1------------------------------

delete from Etudiant where Id_Etudiant=1
delete from Modules where Num_Module=1--------- error impossible fk

------------- SOLUTION---1EXERCISES----------

alter table Noter
drop constraint fk1

---------methode1---------

alter table Noter
add constraint fk1 foreign key (Id_Etudiant) references Etudiant(Id_Etudiant) 
on delete set null

---------affichage---------

select * from Etudiant
select * from Modules
select * from Noter
select * from Groupe

---------Exercises-----------------
--1--L'age des etudiants
SELECT DATEDIFF(YEAR,Date_naiss,GETDATE()) as 'age' from Etudiant 
--2--
Select * from Etudiant where 
YEAR(Date_inscr)=2020
--3--
Select DATEADD(YEAR,DATEDIFF(YEAR,Date_naiss,GETDATE())+1,Date_naiss)
AS 'Dates d''annivairsaires'
from Etudiant
--4--
SELECT * FROM Etudiant where
MONTH(Date_inscr)=11
--5--
SELECT * FROM Etudiant WHERE
MONTH(Date_inscr)=11 and YEAR(Date_inscr)=2020
--6--
SELECT COUNT(Id_Etudiant) AS 'Nombre des �tudiant' FROM Etudiant
WHERE YEAR(Date_inscr) in (2020,2021)

------- L E S J O I N T U R E S ------------------------------
--Liste des noms des �tudiants avec la moyenne :

-- a- Egalit� des cl�s primaires et des cl�s externes :

select e.Nom_Etu, avg(nt.NoteCRR + nt.NoteEFF)/3 as 'Moyenne' 
from Etudiant e,Noter nt 
where e.Id_Etudiant = nt.Id_Etudiant 
group by e.Nom_Etu 
order by avg(nt.NoteCRR + nt.NoteEFF)/3 desc -- ordre des moyennes d�croissant

-- b- Table Inner join Table2 on cl�1 = cl�2 :

select e.Nom_Etu, avg(nt.NoteCRR + nt.NoteEFF)/3 as 'Moyenne' 
from Etudiant e inner join noter nt on e.Id_Etudiant = nt.Id_Etudiant
group by Nom_Etu
order by Moyenne desc -- ordre des moyennes d�croissant

--Liste des noms des �tudiants qui n'ont pas la moyenne g�n�rale:
--utilisation de trois tables

select Nom_Etu,Nom_Module, avg(NoteCRR + NoteEFF)/3 as 'Moyenne' 
from Etudiant e, noter nt, Modules mdl 
where e.Id_Etudiant = nt.Id_Etudiant 
and nt.Num_Module = mdl.Num_Module 
group by Nom_Etu,mdl.Nom_Module having avg(nt.NoteCRR + nt.NoteEFF)/3 <10
order by Moyenne desc

--Liste des noms de tous les �tudiants de la 2�me ann�e 
-- qui n'ont pas la moyenne g�n�rale dans dans le module 08:

select Nom_Etu,mdl.Nom_Module, avg(nt.NoteCRR + nt.NoteEFF)/3 as 'Moyenne' 
from Etudiant e, noter nt, Modules mdl 
where e.Id_Etudiant = nt.Id_Etudiant 
and nt.Num_Module = mdl.Num_Module 
and e.code_groupe in ('TDI201','TDI202') 
and nt.Num_Module = 08
group by Nom_Etu,mdl.Nom_Module having avg(nt.NoteCRR + nt.NoteEFF)/3 <10

--Sous requ�te : Les �tudiants qui n'ont pas de moyennes dans certains modules
-- requ�te ensembliste

select Id_Etudiant,Nom_Etu 
from Etudiant e 
where e.Id_Etudiant in ( select Id_Etudiant
						from Noter nt 
						where (nt.NoteCRR + nt.NoteEFF)/3 <10) 

-- Lister les noms des groupes et le nombre d'admis :
--D'abord Liste des admis --------------------------------

select Id_Etudiant 
from noter n 
group by Id_Etudiant
having avg(NoteCRR + NoteEFF)/3>=10

-----Puis utiliser la liste des admis comme sous requ�te------------------------

select g.nom_groupe,count(e.Id_Etudiant)as "Nombre d'admis" 
from Groupe g,Etudiant e
where g.code_groupe=e.code_groupe
and e.Id_Etudiant in (select Id_Etudiant 
						from noter n 
						group by Id_Etudiant
						having avg(NoteCRR + NoteEFF)/3>=10 ) 
group by g.nom_groupe

-- La fonction top() --Exemple: select top(2) * from Etudiant
--------- Les trois premiers �tudiants qui ont la moyenne-----------------

select top(3) et.Nom_Etu,convert(decimal(4,2), avg( (nt.NoteCRR + nt.NoteEFF)/3 )) 'Moyenne' 
from Etudiant et , Noter nt 
where et.Id_Etudiant=nt.Id_Etudiant 
group by et.Nom_Etu
order by Moyenne desc

-----------------Augmenter une variable------------------------

declare @var int 
set @var=5 
while(@var<20) 
	begin 
		set @var=@var+1 
	end 
select @var

--------------L'instruction while et l'instruction update----------------------- 
-- Tant que la moyenne du module m01 est < 10, ajouter 2 points

while ( select avg(Noter.NoteCRR + Noter.NoteEFF)/3 
		from Noter 
		where Noter.Num_Module = 01 ) <10 
			begin
				update noter set NoteEFF= NoteEFF + 2 where noter.Num_Module = 01
			end

----------------L'instruction Case when--------------------------------------------

select Id_Etudiant, convert(decimal(4,2),AVG((NoteCRR+NoteEFF)/3)) 'Moyenne', 'resultat' =
	case 
		when AVG((NoteCRR+NoteEFF)/3) >= 14 then 'bien' 
		when AVG((NoteCRR+NoteEFF)/3) >=12 then 'A bien'
		when AVG((NoteCRR+NoteEFF)/3) >=10 then 'Passable' 
		else 'Faible' 
	end 
from noter 
group by Id_Etudiant