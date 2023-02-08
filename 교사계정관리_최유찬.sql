-- 계정으로 로그인 후 관리자 기본정보 출력
select * from tblAdmin;

select
    tblAdmin.seq "관리자번호",
    tblAdmin.name as "이름"
from tblAdmin
    where jumin = '1766687';   --로그인 한 관리자의 주민번호 뒷자리(패스워드)


-- 과정명 입력, 출력, 수정, 삭제
select * from tblClass;

insert into tblClass values (courseSeq.nextVal, '과정명');
update tblClass set name = '과정명' where courseSeq = 1;
delete from tblClass where courseSeq = 1;

-- 교재명 입력, 출력, 수정, 삭제
select * from tblBook;

insert into tblBook values (bookSeq.nextVal, '교재명', '출판사');
update tblBook set bookName = '교재명' where bookSeq = 1;
delete from tblBook where bookSeq = 1;

-- 과목명 입력, 출력, 수정, 삭제
select * from tblSubject;

insert into tblSubject values (subSeq.nextVal, '과목명', bookSeq.nextVal);
update tblSubject set name = '과목명' where subSeq = 1;
delete from tblSubject where subSeq = 1;

-- 강의실명 입력, 출력, 수정, 삭제
select * from tblClassRoom;

insert into tblClassRoom values (classroomSeq.nextVal, '강의실명', 30);
update tblClassRoom set name = '<강의실명>' where classRoomSeq = 1;
delete from tblClassRoom where classRoomSeq = 1;




-- 교사정보 등록
insert into tblTeachers values (seqTeachers.nextVal, '홍길동', '1234567', '010-1234-8643', '강의대기');

-- 교사정보 수정
update tblTeachers set name = '교사이름' where name = '홍길동';

-- 교사정보 삭제
delete from tblTeachers where name = '교사이름';

-- 교사정보 조회
select 
    t.name as "이름",
    t.jumin as "주민번호 뒷자리",
    t.tel as "전화번호",
    s.name as "강의 가능 과목"
from tblTeachers t
    inner join tblPossible p
        on t.teacherSeq = p.teacherSeq
            inner join tblSubject s
                on p.subSeq = s.subSeq;

-- 특정 교사의 강의과목에 대한 정보 조회
select * from tblOpenClass;
select
    t.name as 이름,
    s.name as 개설과목,
    os.startdate as 과목시작,
    os.endDate as 과목끝,
    c.name as 과정명,
    oc.startdate as 과정시작,
    oc.enddate as 과정끝,
    b.bookname as 교재명,
    cr.name as 강의실,
    
    case
        when oc.startdate > sysdate then '강의 예정'
        when oc.enddate < sysdate then '강의 종료'
    else '강의 중'
    
end as "진행 상태"

from tblTeachers t
    inner join tblPossible p
        on t.teacherSeq = p.teacherSeq
            inner join tblSubject s
                on p.subSeq = s.subSeq
                    inner join tblOpenSub os
                        on t.teacherSeq = os.teacherSeq
                            inner join tblClassSub cs
                                on s.subSeq = cs.subSeq
                                    inner join tblClass c
                                        on cs.courseSeq = c.courseSeq
                                            inner join tblOpenClass oc
                                                on oc.courseSeq = c.courseSeq
                                                    inner join tblClassRoom cr 
                                                        on cr.classRoomSeq = oc.classRoomSeq
                                                            inner join tblBook b   
                                                                on b.bookSeq = s.bookSeq
                                                                    where t.name = '교사이름';






-- 과정명 추가
insert into tblOpenClass values (courseSeq.nextVal, '과정명'); 


-- 과정명 및 강의실 정보 조회
select 
    name as 과정명
from tblClass;

select 
    classroomSeq as 강의실번호,
    name as 강의실명,
    stuLimit as 학생정원
from tblClassRoom;

-- 개설 과정 정보 출력 시 개설 과정명, 개설 과정기간, 강의실명, 개설 과목 등록 여부, 교육생 등록 인원 출력
select
    c.name as "개설과정명",
    oc.startdate as "과정시작",
    oc.enddate as "과정끝",
    cr.name as "강의실명",
    p.등록인원
from tblOpenClass oc
    inner join tblclass c
        on oc.courseSeq = c.courseSeq
            inner join tblClassroom cr
                on oc.classroomSeq = cr.classroomSeq
                    inner join (select
                                    openSeq, 
                                    count(stuSeq) as "등록인원"
                                from tblApply
                                group by openSeq) p
                        on oc.openSeq = p.openSeq
                        order by oc.openSeq;



-- 개설 과정 등록 
insert into tblOpenClass values (openSeq.nextVal, '2023-02-08', '2023-06-10', '4개월', 30, 1, 1);

-- 개설 과정 정보 수정
update tblOpenClass set <변경할 컬럼> = <변경할 값> where <변경할 컬럼> = <컬럼 값>;

-- 과정 조회 과정명, 과정기간, 강의실명,  교육생 등록인원을 출력한다.
select 
    c.name as 과정명,
    oc.startdate as 과정시작,
    oc.enddate as 과정끝, 
    cr.name as 강의실명,
    oc.stulimit as 교육생등록인원
    
from tblOpenClass oc
    inner join tblClassRoom cr
        on cr.classroomSeq = oc.classroomSeq
            inner join tblClass c
                on c.courseSeq = oc.courseSeq;
                
-- 특정 개설 과정 선택 시 개설과목정보(과목명, 과목기간, 교재명, 교사명)과 교육생 정보(이름, 주민번호 뒷자리, 전화번호, 등록일, 수료 및 중도탈락)을 출력한다.
select * from tblOpenClass;

select
    s.name as 과목명,
    os.startdate as 과목시작,
    os.enddate as 과목끝,
    b.bookname as 교재명,
    t.name as 교사명,
    st.name as 학생명,
    st.jumin as 학생주민번호,
    st.tel as 학생전화번호,
    st.regdate as 등록일,
    case
        when st.fail is not null then '중도탈락'
        when st.fail is null then '수료'
    end as "상태"
    
from tblOpenClass oc
    inner join tblClassOpen co
        on oc.openSeq = co.openSeq
            inner join tblOpenSub os
                on os.opensubSeq = co.opensubSeq
                    inner join tblSubject s
                        on s.subSeq = os.subSeq
                            inner join tblBook b
                                on b.bookSeq = s.bookSeq
                                    inner join tblTeachers t
                                        on t.teacherSeq = os.teacherSeq
                                            inner join tblApply a
                                                on oc.openSeq = a.openSeq
                                                    inner join tblStudents st
                                                        on st.stuSeq = a.stuSeq
    where oc.openSeq = 1;


-- 과정 수료 처리
update tblStudents s set s.enddate = '2022-08-23' where sysdate > (select oc.enddate from tblOpenClass oc where oc.openSeq = '1');





-- 개설 과목 등록
insert into tblOpenSub values (openSubSeq.nextVal, '<개설과목시작>', '<개설과목끝>', <과목번호>, <교사번호>, <배점번호>);

-- 개설 과목 정보 수정(기간)
update tblOpenSub set startDate = '<개설과목시작>', endDate = '<개설과목끝>' where opensubSeq = <개설과목번호>;

-- 개설 과목 출력 시 개설 과정 정보, 과목명, 과목기간, 교재명, 교사명을 출력한다
select
    os.openSubSeq as 개설과정번호,
    s.name  as 과목명,
    os.startdate as 과목시작,
    os.enddate as 과목끝,
    b.bookName as 교재명,
    t.name as 교사명
from tblOpenSub os
    inner join tblSubject s
        on os.subSeq = s.subSeq
            inner join tblBook b
                on b.bookSeq = s.bookSeq
                    inner join tblTeachers t
                        on t.teacherSeq = os.teacherSeq;







-- 교육생 등록  - 교육생 이름, 주민번호 뒷자리, 전화번호, 등록일
insert into tblStudents values (stuSeq.nextVal, '김길동', '2347890', '010-2536-3499', sysdate, null, null);


-- 교육생 정보 수정
update tblStudents set <수정할컬럼> = <수정할 값> where <수정할 컬럼> = <컬럼 값>; 

-- 교육생 삭제
delete from tblStundents where stuSeq = 1;

-- 교육생 조회
select 
    name, 
    jumin,
    tel, 
    regdate
from tblStudents;

-- 검색 기능을 사용하여 출력한다.
select 
    name, 
    jumin,
    tel, 
    regdate
from tblStudents
    where name like ‘%길동%’;

-- 특정 교육생 선택 시 수강신청 또는 수강중인, 수강했던 과정 정보(과정명, 과정기간, 강의실, 수료 및 중도탈락 여부, 수료 및 중도탈락 날짜)를 출력한다.
select
    s.name as 학생명,
    c.name as 과정명,
    oc.startdate as 과정시작,
    oc.enddate as 과정끝,
    cr.name as 강의실,
    s.fail as 중도탈락여부,
    s.enddate as 수료날짜
from tblStudents s
        inner join tblApply a
            on s.stuSeq = a.stuSeq
                inner join tblOpenClass oc
                    on oc.openSeq = a.openSeq
                        inner join tblClass c
                            on c.courseSeq = oc.courseSeq
                                inner join tblClassroom cr
                                    on cr.classroomSeq = oc.classroomSeq
                             where s.name = '정다예';

-- 강의 종료된 과정 목록에서 선택한 과정의 교육생 정보를 확인할 수 있다. (졸업생 정보)
select 
    s.stuSeq as 학생번호,
    s.name as 학생이름,
    s.jumin as 주민번호,
    s.tel as 전화번호,
    s.regdate as 등록일,
    s.enddate as 수료일
from tblStudents s
    inner join tblApply a
        on s.stuSeq = a.stuSeq
            inner join tblOpenClass oc
                on oc.openSeq = a.openSeq
                    where oc.enddate < sysdate and s.enddate is not null;
                    
                    
                    


