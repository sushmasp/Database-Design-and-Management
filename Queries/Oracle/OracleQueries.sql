--SCHOOL ADMINISTRATOR :

--ACADEMIC PERFORMANCE: 

--Query to fetch the average student grade in each subject 

--This query is to fetch the average student grades in each subject. This is done by taking the average student grade in first and second semester and then taking the average of both semesters.

SELECT SubjectID,
       SubjectName,
	 ROUND( AVG(AverageGrade),4) AverageStudentNumericalGrade
FROM(
SELECT e.SubjectID SubjectID,
       e.SubjectName SubjectName,
	 d.GradeType GradeType,
       AVG(b.NumericGrade) AverageGrade
FROM factStudentCourse a
JOIN factStudentCourseGrade b 
ON a.StudentCourseID = b.StudentCourseID
JOIN dimCourse c
ON a.CourseID = c.CourseID
JOIN dimGradeType d 
ON d.GradeTypeID = b.GradeTypeID
JOIN dimSubject e
ON c.SubjectID = e.SubjectID
WHERE b.GradeTypeID IN(5,11)
GROUP BY e.SubjectID,e.SubjectName,d.GradeType
)Main
GROUP BY SubjectID, SubjectName
ORDER BY SubjectID;



--Query to rank the staff under each facility for each course

--This query is to rank the staff for each course in each facility. In a facility two staff may be teaching a course.So depending on the student performance under that staff we will rank the staff.


SELECT sc.FacilityID,
       f.FacilityName,
       sc.CourseID,
       CourseTitle,
       s.StaffName,
       ROUND(AVG(NumericGrade),4) "Average_Student_Performance",
       DENSE_RANK() OVER(PARTITION BY sc.CourseID ORDER BY AVG(NumericGrade) DESC) "Ranking"
FROM DIMCOURSE c
JOIN factStudentCourse sc ON c.CourseID = sc.CourseID
JOIN dimStaff s ON s.StaffID = sc.StaffID
JOIN factStudentCourseGrade scg ON sc.StudentCourseID = scg.StudentCourseID
JOIN dimFacility f ON sc.FacilityID = f.FacilityID
GROUP BY sc.FacilityID,f.FacilityName,CourseTitle,sc.CourseID,s.StaffName
ORDER BY sc.CourseID;

--STUDENT ABSENCES:

--Query to fetch the absence counts for each facility in each year

--This query will fetch the total student absence count for each year in each facility.

SELECT EXTRACT(YEAR FROM a.AbsenceDate) AcademicYear,a.FacilityID,b.FacilityName,COUNT(*) Absence_Count
FROM factAbsence a
JOIN dimFacility b 
ON a.FacilityID = b.FacilityID
GROUP BY a.FacilityID,b.FacilityName,EXTRACT(YEAR FROM a.AbsenceDate)
ORDER BY AcademicYear,a.FacilityID;

--STUDENT MISBEHAVIOR AND DISCIPLINE:

--Query to fetch the misbehavior counts for each facility
--This query will fetch the misbehavior counts for each facility.

SELECT EXTRACT (YEAR FROM a.EventDate) AcademicYear,EventFacilityID FacilityID,b.FacilityName, COUNT(*) Student_Count
FROM factDiscipline a
JOIN dimFacility b ON a.EventFacilityID = b.FacilityID
GROUP BY a.EventFacilityID,b.FacilityName,EXTRACT (YEAR FROM a.EventDate)
ORDER BY AcademicYear,a.EventFacilityID;



--Query to fetch the misbehavior counts for each facility under event code (misbehavior type)
--This query will fetch the count of students who did misbehave according to each misbehavior category under each facility.

SELECT EventFacilityID FacilityID,b.FacilityName,a.DisciplineEventCodeID,c.DisciplineEventDesc, COUNT(*) Student_Count
FROM factDiscipline a
JOIN dimFacility b ON a.EventFacilityID = b.FacilityID
JOIN dimDisciplineEventCode c ON a.DisciplineEventCodeID = c.DisciplineEventCodeID
GROUP BY a.EventFacilityID,b.FacilityName,a.DisciplineEventCodeID,c.DisciplineEventDesc
ORDER BY a.EventFacilityID;

--SPECIAL NEEDS PROGRAM :

--Query to fetch the number of students under each special program
--This query fetches the count of students enrolled for each special program.
	
select a.ProgramID,b.Program,count(*) Student_Count from factSpecialProgram a
JOIN dimSpecialProgram b
ON a.ProgramID = b.ProgramID
GROUP BY a.ProgramID,b.Program;


--OVERALL :

--Query to fetch number of students in each course (to find popular course)
--This query will fetch the number of students in each course. This will help School Administrator to identify the popular course.

select b.CourseID,c.CourseTitle,count(*) StudentCount 
from dimStudent a
join factStudentCourse b
on a.StudentID=b.StudentID
join dimCourse c
on b.CourseID=c.CourseID
group by b.CourseID,c.CourseTitle
Order by StudentCount DESC;

--Query to rank the student enrollment count each year
--This query will fetch the number of students enrolled each year.

select EXTRACT (year FROM b.EnrollmentDate) YearofEnrollment, count(*)  noofstudentsenrolled,RANK()OVER (ORDER BY count(*) desc) Ranking
from dimStudent a 
join factStudentCourse b
on a.StudentID=b.StudentID
group by EXTRACT (year FROM b.EnrollmentDate);


--Query to fetch average student performance for each course for each staff
--This query will fetch the average student performance for all the courses a staff is teaching. It fetches the results for all the staff.
SELECT s.StaffName,sc.CourseID,CourseTitle,ROUND (AVG(NumericGrade),4) Average_grade
FROM dimCourse c
JOIN factStudentCourse sc 
ON c.CourseID = sc.CourseID
JOIN dimStaff s 
ON s.StaffID = sc.StaffID
JOIN factStudentCourseGrade scg  
ON sc.StudentCourseID = scg.StudentCourseID
GROUP BY s.StaffName,CourseTitle,sc.CourseID
ORDER BY s.StaffName,sc.CourseID;



TEACHER:

STUDENT ACADMIC PERFORMANCE:

--Query to fetch the number of students getting highest grade for each grade type
--This query will fetch the number of students scoring highest grade at each specific grade type (like Final exam, 1st semester etc.) for each course. 
select a.StaffID, sc.CourseID,CourseTitle,GradeType, count(StudentID) NumberofStudentswithAgrade from dimCourse c 
join factStudentCourse sc on c.CourseID= sc.CourseID
join factStudentCourseGrade scg on sc.StudentCourseID=scg.StudentCourseID
join dimGradeType gt on scg.GradeTypeID=gt.GradeTypeID
join dimStaff a on sc.StaffID=a.StaffID 
where scg.AlphaGrade ='A' and a.StaffID='62'
group by c.CourseTitle,sc.CourseID, gt.GradeType,a.StaffID
order by sc.CourseID;


--Query to fetch the average student performance in each course he is teaching
--This query is to fetch the average student performance of all courses a staff is teaching.
select  sc.CourseID,CourseTitle,ROUND(Avg(NumericGrade),4) Average_grade
from dimCoursE c 
join factStudentCourse sc on c.CourseID= sc.CourseID
join  dimStaff s on s.StaffID = sc.StaffID
join factStudentCourseGrade scg on sc.StudentCourseID= scg.StudentCourseID where s.StaffName ='David Alexander'
group by CourseTitle,sc.CourseID;


--Query to fetch the count of each grade for each course he is teaching for first and second semester
--This query fetch the count of each grade for each course under each grade type under David Alexander (For example: no of A in his course)

select StaffName,sc.CourseID,CourseTitle,gt.GradeType,scg.AlphaGrade,count(*) StudentCount from dimCourse c 
join factStudentCourse sc on c.CourseID= sc.CourseID
join dimStaff s on s.StaffID = sc.StaffID
join factStudentCourseGrade scg on sc.StudentCourseID= scg.StudentCourseID
join dimGradeType gt on scg.GradeTypeID=gt.GradeTypeID
where StaffName= 'David Alexander' AND gt.GradeTypeID IN(5,11)
group by sc.CourseID,CourseTitle,scg.AlphaGrade,gt.GradeType,StaffName
order by sc.CourseID,gt.GradeType;


-- Query to fetch the Bottom 10 students based on their grade for specific grade type for a specific course

--This query fetch the fetch the Bottom 10 students based on their grade for specific grade type for a specific course

SELECT s.StudentFirstName,c.CourseTitle,scg.NumericGrade,st.StaffName FROM dimCourse c
JOIN factStudentCourse sc
ON c.CourseID = sc.CourseID
JOIN dimStaff st 
ON st.StaffID = sc.StaffID
JOIN dimStudent s 
ON s.StudentID = sc.StudentID
JOIN factStudentCourseGrade scg 
ON sc.StudentCourseID = scg.StudentCourseID
JOIN dimGradeType gt 
ON scg.GradeTypeID = gt.GradeTypeID
WHERE st.StaffID = 9 AND ROWNUM <=10
AND c.CourseTitle = '9TH GRD STUDY SKILLS'
AND gt.GradeType = 'First Semester'
ORDER BY scg.NumericGrade  


--STUDENT ABSENCES :

--Query to fetch the number of students absent for his course
--This query will fetch the number of students absent for the courses he is teaching.
select StaffName,sc.CourseID,c.CourseTitle, count(*) NoofStudentsAbsent
from  factAbsence a
join factStudentCourse sc on a.StudentID= sc.StudentID
join dimCourse c on sc.CourseID= c.CourseID 
join dimStaff s on s.StaffID = sc.StaffID
where StaffName = 'David Alexander' 
group by sc.CourseID,c.CourseTitle,StaffName 
order by  NoofStudentsAbsent desc;

--STUDENT MISBEHAVIOR AND DISCIPLINE
--Query to fetch the number of students reported by a particular staff in each course he is teaching

--This query will fetch the number of students reported by a specific staff in each course he is teaching.
SELECT s.StaffName,sc.CourseID,c.CourseTitle,COUNT(fd.StudentID) NumberofStudents
FROM factDiscipline fd
join factStudentCourse sc on fd.StudentID= sc.StudentID
join  dimCourse c on sc.CourseID= c.CourseID 
JOIN dimStaff s 
ON fd.EventReportingStaffID = s.StaffID
JOIN dimDisciplineEventCode dac 
ON fd.DisciplineEventCodeID = dac.DisciplineEventCodeID 
WHERE fd.EventReportingStaffID=6
GROUP BY s.StaffName,sc.CourseID,c.CourseTitle
ORDER BY   NumberofStudents DESC;



--PARENT :


--STUDENT ACADEMIC PERFORMANCE:
--Query to fetch the course grade of a specific student for each course at a specific grade type
--  This query will fetch the course grade of a specific student for each course for specific grade type (1st semester/2nd semester)

 select b.CourseID,d.CourseTitle,a.NumericGrade from factStudentCourseGrade a
  join factStudentCourse b
  on a.StudentCourseID=b.StudentCourseID
  join dimGradeType c
  on a.GradeTypeID=c.GradeTypeID
  Join dimCourse d
  ON d.CourseID = b.CourseID
  where GradeType='Second Semester' and b.StudentID='48';

--Query to fetch the student performance of a particular student in various years
--This query is used by the parent to see his child’s performance each year. This is used for performance measurement analysis. 

SELECT e.SchoolYear,ROUND(AVG(a.NumericGrade),4) Yearly_Perforamnce
FROM factStudentCourseGrade a
JOIN factStudentCourse b
ON a.StudentCourseID = b.StudentCourseID
JOIN dimStudent e 
ON b.StudentID = e.StudentID
WHERE a.GradeTypeID =11 AND e.StudentName='Kim Abercrombie'
GROUP BY SchoolYear;

-- Query to fetch the courses in which a student scored well

--This query will fetch the courses in which he scored well.
SELECT a.StudentID,a.StudentName,d.CourseTitle,c.AlphaGrade
FROM dimStudent a
JOIN factStudentCourse b ON b.StudentID = a.StudentID
JOIN factStudentCourseGrade c ON c.StudentCourseID = b.StudentCourseID
JOIN dimCourse d ON b.CourseID = d.CourseID
WHERE a.StudentID = '1' AND c.AlphaGrade = 'A'
GROUP BY c.AlphaGrade,a.StudentID,a.StudentName,d.CourseTitle;


--Query to fetch the absent counts (number of absent days) of a specific student
--This query will fetch the absent counts (number of absent days) of a specific student.

SELECT COUNT(AbsenceCount) numberofdaysabsent
FROM factAbsence a
WHERE StudentID = '1660';

--Query to fetch the misbehavior details of a specific student 
--This query will fetch the misbehavior details of a specific student.
SELECT StudentID,b.DisciplineActionCodeID,DisciplineActionDesc,a.DisciplineEventCodeID,DisciplineEventDesc,ActionDate
FROM factDiscipline a
JOIN dimDisciplineActionCode b
ON a.DisciplineActionCodeID = b.DisciplineActionCodeID
JOIN dimDisciplineEventCode c 
ON c.DisciplineEventCodeID = a.DisciplineEventCodeID
WHERE StudentID = '1'
ORDER BY StudentID,DisciplineActionDesc,DisciplineEventDesc;

--Query to fetch the special program details of a specific student enrolled to
--This query will fetch the special program details for which a specific student is enrolled to.

SELECT StudentID,b.ProgramID,programcode,b.Program,EntryDate
FROM factSpecialProgram a
JOIN dimSpecialProgram b
ON a.ProgramID = b.ProgramID
WHERE StudentID = '32';



--Overall:


--Query to fetch the courses and respective professors of a specific student
--This query will fetch the courses and staff details of a particular student.
SELECT a.StudentID,a.CourseID,b.CourseTitle,a.StaffID,c.StaffName
FROM factStudentCourse a
JOIN dimCourse b 
ON a.CourseID = b.CourseID
JOIN dimStaff c 
ON a.StaffID = c.StaffID
WHERE a.StudentID = 12;










