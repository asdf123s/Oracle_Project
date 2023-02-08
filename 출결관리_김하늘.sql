

--1. 특정 개설 과정 선택시 1)개설과목별정보 + 2)개설과정정보
-- 개설과정명, 강의실명 중복을 없애기 위해 2개로 나눔.

--1)개설 과목별 정보 출력(개설과목명, 과목시작일, 과목종료일, 교재명, 교사명)
select 
    j.name as "개설 과목명",
    to_char(o.startDate, 'yyyy-mm-dd') as "과목시작일",
    to_char(o.endDate, 'yyyy-mm-dd') as "과목종료일", 
    b.bookname as "교재명",
    t.name as "교사명"
from tblOpenSub o
    inner join tblClassOpen c
        on o.openSubSeq = c.openSubSeq
            inner join tblOpenClass p
                on p.openSeq = c.openSeq
                    inner join tblSubject j
                        on j.subSeq = o.subSeq
                            inner join tblBook b
                                on b.bookSeq = j.bookSeq
                                    inner join tblTeachers t
                                        on t.teacherSeq = o.teacherSeq
                                            where c.openSeq = 1
                                                order by c.openSeq asc;
--2)개설 과정 정보 출력(개설과정명, 강의실명)

select
    c.name as "개설과정명",
    r.name as "강의실명"
from tblClass c
    inner join tblOpenClass o
        on c.courseSeq = o.courseSeq
            inner join tblClassRoom r
                on r.classRoomSeq = o.classRoomSeq
                    where o.courseSeq = 1;

--2. 개설 과목 별로 성적 등록 여부, 시험 문제 파일 등록 여부를 확인

select
    distinct
    j.name as "개설과목명",
    case
        when g.stuSeq = s.stuSeq then 'Y'
        else 'N'
    end as "성적 등록 여부",
    case
        when w.testSeq is not null then 'Y'
        else 'N'
    end as "전체필기시험등록여부",
    case
        when p1.testSeq is not null then 'Y'
        else 'N'
    end as "전체실기시험등록여부"
from tblOpenSub o
    inner join tblGrade g
        on o.openSubSeq = g.openSubSeq
            inner join tblStudents s
                on s.stuSeq = g.stuSeq
                    inner join tblClassOpen p
                        on p.openSubSeq = o.openSubSeq
                            inner join tblWTest w
                                on o.openSubSeq = w.openSubSeq
                                    inner join tblPTest p1
                                        on p1.openSubSeq = o.openSubSeq
                                            inner join tblSubject j
                                                on j.subSeq = o.subSeq
                                                    where o.openSubSeq = 1;

--3. 과목별 성적 출력시 1) 개설과목별정보 + 2)교육생정보
-- 교육생 정보 중복을 없애기 위해 2개로 나눔.

--1) 개설과목별정보(과정명, 과정기간, 강의실명, 과목명, 교사명, 교재명)

select
    c2.name as "과정명",
    to_char(c1.startDate, 'yyyy-mm-dd') || '~' || to_char(c1.endDate, 'yyyy-mm-dd') as "과정기간",
    r.name as "강의실명",
    s.name as "과목명",
    t.name as "교사명",
    b.bookName as "교재명"
from tblOpenSub o
    inner join tblSubject s
        on s.subSeq = o.subSeq
            inner join tblClassOpen c
                on c.openSubSeq = o.openSubSeq
                    inner join tblOpenClass c1
                        on c1.openSeq = c.openSeq
                            inner join tblClassRoom r
                                on r.classRoomSeq = c1.classRoomSeq
                                    inner join tblClass c2
                                        on c2.courseSeq = c1.courseSeq
                                            inner join tblBook b
                                                on b.bookSeq = s.bookSeq
                                                    inner join tblTeachers t
                                                        on t.teacherSeq = o.teacherSeq
                                                            where o.openSubSeq = 1;

--2)개설 과목별 교육생의 성적 정보(교육생 이름, 주민번호 뒷자리, 출결, 필기, 실기)

select 
    t.name as "교육생 이름",
    t.jumin as "주민번호 뒷자리",
    g.attScore as "출결",
    g.writeScore as "필기",
    g.pracScore as "실기"
from tblOpenSub o
    inner join tblGrade g
        on g.openSubSeq = o.openSubSeq
            inner join tblStudents t
                on t.stuSeq = g.stuSeq
                    where o.openSubSeq = 1
                        order by t.stuSeq asc;

-- 4.교육생 개인별 성적 출력시 1) 교육생정보+2)교육생이 수강한 개설과목에 대한 성적 정보 
-- 교육생 정보 중복을 없애기 위해 2개로 나눔.

--1)교육생 정보(이름, 주민번호 뒷자리, 과정명, 과정기간, 강의실명)

select 
    distinct
    t.name as "이름",
    t.jumin as "주민번호 뒷자리",
    s.name as "과정명",
    to_char(p.startDate, 'yyyy-mm-dd') || '~' || to_char(p.endDate, 'yyyy-mm-dd') as "과정기간",
    r.name as "강의실명"
from tblStudents t
    inner join tblGrade g
        on t.stuSeq = g.stuSeq
            inner join tblOpenSub o
                on o.openSubSeq = g.openSubSeq
                    inner join tblClassOpen c
                        on c.openSubSeq = o.openSubSeq
                            inner join tblOpenClass p
                                on p.openSeq = c.openSeq
                                    inner join tblClass s
                                        on s.courseSeq = p.courseSeq
                                            inner join tblClassRoom r
                                                on r.classRoomSeq = p.classRoomSeq
                                                    where t.stuSeq = 1;
-- 2) 교육생이 수강한 개설과목에 대한 성적 정보(과목명, 과목기간, 교사명, 출결, 필기, 실기)

select 
    distinct
    j.name as "과목명",
    to_char(o.startDate, 'yyyy-mm-dd') || '~' || to_char(o.endDate, 'yyyy-mm-dd') as "과목기간",
    t.name as "교사명",
    g.attScore as "출결",
    g.writeScore as "필기",
    g.pracScore as "실기"
from tblOpenSub o
    inner join tblSubject j
        on j.subSeq = o.subSeq
            inner join tblGrade g
                on o.openSubSeq = g.openSubSeq
                    inner join tblTeachers t
                        on t.teacherSeq = o.teacherSeq
                            inner join tblStudents d
                                on d.stuSeq = g.stuSeq
                                    where d.stuSeq = 1
                                        order by d.stuSeq asc;

--5. 강의실별 재시험 교육생 출력(재시험 날짜, 과목명, 교육생 이름)

select
    to_char(t.reTestDate, 'yyyy-mm-dd') as "재시험 날짜",
    j.name as "과목명",
    s.name as "교육생 이름"
from tblOpenSub o
    inner join tblSubject j
        on o.subSeq = j.subSeq
            inner join tblGrade g
                on g.openSubSeq = o.openSubSeq
                    inner join tblStudents s
                        on s.stuSeq = g.stuSeq
                            inner join tblReTest t
                                on t.gradeSeq = g.gradeSeq
                                    inner join tblClassOpen c
                                        on c.openSubSeq = o.openSubSeq
                                            inner join tblOpenClass c1
                                                on c1.openSeq = c.openSeq
                                                    inner join tblClassRoom r
                                                        on r.classRoomSeq = c1.classRoomSeq
                                                            where r.classRoomSeq = 1;
                                                            
                                                            
                                                            



-- 출결 현황을 기간별(년, 월, 일) 출력시(교육생 이름, 날짜, 출결상태)

select
    s.name as "교육생 이름",
    to_char(attdate, 'yyyy-mm-dd') as “날짜",
    a.attendance as "출결"
from tblStudents s
    inner join tblAtt a
        on s.stuSeq = a.stuSeq
            full outer join tblHoliday h
                on h.regDate = a.attDate
                    where to_char(a.attdate, 'd') <> '1' and to_char(a.attdate, 'd') <> '7' 
                        and h.name is null
                        and attdate between to_date('2022-06-20', 'yyyy-mm-dd') and to_date('2022-06-24', 'yyyy-mm-dd')
                        order by to_char(attdate, 'yyyy-mm-dd') asc;

--2. 교육생 월별 근태 상황 출력시(정상, 지각, 조퇴, 외출, 병가, 기타)

select
    to_char(attdate, 'mm') as "교육생 월별 출결",
    count(a.attendance) as "출결",
    count(case
        when a.attendance = '정상' then '정상'
    end) as "정상",
    count(case
        when a.attendance = '지각' then '지각'
    end) as "지각",
    count(case
        when a.attendance = '조퇴' then '조퇴'
    end) as "조퇴",
    count(case
        when a.attendance = '외출' then '외출'
    end) as "외출",
    count(case
        when a.attendance = '병가' then '병가'
    end) as "병가",
    count(case
        when a.attendance = '기타' then '기타'
    end) as "결석"
from tblStudents s
    inner join tblAtt a
        on s.stuSeq = a.stuSeq
             full outer join tblHoliday h
                on h.regDate = a.attDate
                    where to_char(a.attdate, 'd') <> '1' and to_char(a.attdate, 'd') <> '7' 
                        and attdate between to_date('1', 'mm') and to_date('7', 'mm') and s.stuSeq = 1
                        and h.name is null
                            group by to_char(attdate, 'mm')
                                order by to_char(attdate, 'mm') asc;

-- 3. 특정 인원 출결 현황 출력시(교육생 이름, 날짜, 출결)

select
    s.name as "교육생이름",
    a.attDate as "날짜",
    a.attendance as "출결"
from tblAtt a
    inner join tblStudents s
        on a.stuSeq = s.stuSeq
            full outer join tblHoliday h
                on h.regDate = a.attDate
                    where to_char(a.attdate, 'd') <> '1' and to_char(a.attdate, 'd') <> '7' 
                        and s.stuSeq = 1
                        and h.name is null
                            order by a.attDate asc;

--4. 특정 개설과정 선택 시 모든 교육생 정보 출력(학생번호, 과정번호, 과정기간, 수강정원, 교육생 이름, 날짜, 근태기록)

select
    distinct
    t.stuSeq as "학생번호",
    s.courseSeq as "과정번호",
    to_char(p.startDate, 'yyyy-mm-dd') || '~' || to_char(p.endDate, 'yyyy-mm-dd') as "과정기간",
    p.stuLimit as "수강정원",
    t.name as "교육생 이름",
    a.attDate as "날짜",
    a.attendance as "근태기록"
from tblAtt a
    inner join tblStudents t
        on t.stuSeq = a.stuSeq
            inner join tblGrade g
                on g.stuSeq = t.stuSeq
                    inner join tblOpenSUb o
                        on o.openSubSeq = g.openSubSeq
                            inner join tblClassOpen c
                                on c.openSubSeq = o.openSubSeq
                                    inner join tblOpenClass p
                                        on p.openSeq = c.openSeq
                                            inner join tblClass s
                                                on s.courseSeq = p.courseSeq
                                                    full outer join tblHoliday h
                                                        on h.regDate = a.attDate
                                                            where p.openSeq = 1
                                                                and to_char(a.attdate, 'd') <> '1' and to_char(a.attdate, 'd') <> '7'
                                                                and h.name is null
                                                                    order by attDate asc;







--1.교육생별 취업현황 출력시(교육생이름, 취업현황, 취업날짜, 회사명, 과정명)

select
    s.name as "교육생이름",
    e.employNow as "취업현황",
    e.employDate as "취업날짜",
    e.company as "회사명",
    c1.name as "과정명"
from tblStudents s
    inner join tblStudentEmp e
        on s.stuSeq = e.stuSeq
            inner join tblOpenClass c
                on c.openSeq = e.openSeq
                    inner join tblClass c1
                        on c1.courseSeq = c.courseSeq
                            where e.employmentSeq = 1;

-- 교육생 취업현황 수정
update tblStudents set name = 정다예 where stuSeq = 1;
update tblStudentEmp set employNow = '취업' where employmentSeq = 1;
update tblStudentEmp set employDate = sysdate where employmentSeq = 1;
update tblStudentEmp set company = '회사명' where employmentSeq = 1;
update tblClass set name = '과정명' where courseSeq = 1;

--2. 교사별 취업현황 출력시 (과정명, 과정을 들은 교육생 수, 취업을 한 교육생 수, 가르친 교육생의 취업률(%))

select 
    distinct
    ts.teacherSeq as "교사번호",
    p.openSeq as "개설과정번호",
    c.name as "과정명",
    count(*) as "과정을 들은 교육생 수",
    count(case
        when e.employNow = '취업' then '취업'
    end) as "취업을 한 교육생 수",
    round(count(case
        when e.employNow = '취업' then '취업'
    end) / count(*) * 100, 1) as "교육생의취업률(%)"
from tblOpenClass p
    inner join tblClass c
        on p.courseSeq = c.courseSeq
            inner join tblApply a
                on a.openSeq = p.openSeq
                    inner join tblStudentEmp e
                        on e.openSeq = p.openSeq
                            inner join tblStudents t
                                on t.stuSeq = a.stuSeq
                                    inner join tblClassOpen co
                                        on co.openSeq = p.openSeq
                                            inner join tblOpenSub o
                                                on o.openSubSeq = co.openSubSeq
                                                    inner join tblTeachers ts
                                                        on ts.teacherSeq = o.teacherSeq
                                                            where ts.teacherSeq = 1 and endDate < sysdate
                                                                group by ts.teacherSeq, p.openSeq, c.name, t.stuSeq
                                                                    order by ts.teacherSeq, p.openSeq asc;

--3. 기간별 취업현황 출력시(취업년도, 취업한 교육생 수)

select  
    to_char(employDate, 'yyyy') as "취업년도",
    count(*) as "취업한 교육생 수"
from tblStudentEmp
    group by to_char(employDate, 'yyyy')
        having to_char(employDate, 'yyyy') is not null;





--게시판 정보 출력시(게시글, 게시날짜, 작성자(교사명, 교육생 이름), 댓글)

select
    b.content as "게시글",
    b.postdate as "게시날짜",
    t.name as "교사명",
    s.name as "교육생 이름",
    c.content as "댓글"
from tblBoard b
    left outer join tblComment c
        on c.boardSeq = b.boardSeq
            left outer join tblStudents s
                on c.stuSeq = s.stuSeq
                    left outer join tblTeachers t
                        on c.teacherSeq = t.teacherSeq
                            order by postDate asc;

-- 게시판 글 수정
update tblBoard set content = '게시글' where boardSeq = 1;

-- 게시판 글 삭제 + 게시판 글 삭제하기 위해 테이블 제약사항 변경
alter table tblComment drop constraint SYS_C007811;
alter table tblComment add constraint fk_content foreign key(boardSeq) references tblBoard(boardSeq) on delete cascade;
delete from tblBoard where boardSeq = 1;





--강의 평가 정보 출력시(과정명, 강의평가 내용, 작성자(교육생))

select
    distinct
    c.name as "과정명",
    e.content as "강의평가 내용",
    s.name as "작성자(교육생)"
from tblEvaluation e
    left outer join tblStudents s
        on e.stuSeq = s.stuSeq
            inner join tblStudentEmp e
                on e.stuSeq = s.stuSeq
                    inner join tblOpenClass p
                        on p.openSeq = e.openSeq
                            inner join tblClass c
                                on c.courseSeq = p.courseSeq
                                    where p.courseSeq = 1;

-- 강의평가 삭제          
delete from tblEvaluation where evaluationSeq = 1;

