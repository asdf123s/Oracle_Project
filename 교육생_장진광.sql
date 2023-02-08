- 교육생은 시스템의 일부 기능을 로그인 과정을 거친 후에 사용할 수 있다.
- 비밀번호는 교육생 본인의 주민번호 뒷자리이다.
- 로그인에 성공하면 개인정보와 수강 정보를 타이틀로 출력한다.
select
    s.stuSeq as "교육생 번호",
    s.name as "교육생 이름",
    s.jumin as "주민등록번호(뒷자리)",
    s.tel as "전화번호",
    c.name as "과정명",
    o.startDate as "과정 개강",
    o.endDate as "과정 종강",
    r.name as "강의실"
from tblStudents s
    inner join tblApply a
        on s.stuSeq = a.stuSeq
            inner join tblOpenClass o
                on o.openSeq = a.openSeq
                    inner join tblClass c
                        on c.courseSeq = o.courseSeq
                            inner join tblClassRoom r
                                on r.classRoomSeq = o.classRoomSeq
where jumin = '1861175';


--교육생 개인의 성적 정보를 출력
--성적 정보는 과목별 목록형태로 출력된다.

select
    s.stuSeq,
    sj.subSeq as "과목번호",
    sj.name as "과목명",
    os.startDate as "과목 시작날",
    os.endDate as "과목 종료날",
    t.name  as "교사명",
    b.bookname  as "교재명",
    p.attendance as "출결",
    p.write as "필기",
    p.practice as "실기",
    g.attScore as "출결점수",
    g.writeScore as "필기점수" ,
    g.pracScore as "실기점수",
    wt.testDate as "필기시험날짜",
    pt.testDate as "실기시험날짜"
from tblStudents s
    inner join tblGrade g
        on s.stuSeq = g.stuSeq
            inner join tblOpenSub os
                on os.openSubSeq = g.openSubSeq
                    inner join tblTeachers t
                        on t.teacherSeq = os.teacherSeq
                            inner join tblPoint p
                                on p.pointSeq = os.pointSeq
                                    inner join tblSubject sj
                                        on sj.subSeq = os.subSeq
                                            inner join tblWTest wt
                                                on os.openSubSeq = wt.openSubSeq
                                                    inner join tblPTest pt
                                                        on os.openSubSeq = pt.openSubSeq
                                                              inner join tblBook b
                                                                   on b.bookSeq = sj.bookSeq
where jumin = '1861175';



--본인의 출결 현황을 기간별(전체, 월, 일) 조회할 수 있어야 한다.

--출결관리 및 출결 조회(전체)
select
    a.attDate as "날짜",
    a.attendance "출결"
from tblStudents s
    inner join tblAtt a
        on s.stuSeq = a.stuSeq
            where s.jumin = '1861175';

--출결관리 및 출결 조회(월)
select
    a.attDate as "날짜",
    a.attendance "출결"
from tblStudents s
    inner join tblAtt a
        on s.stuSeq = a.stuSeq
    where a.attDate between to_date('2022-03-01'>, 'yyyy-mm-dd')
                        and to_date(<'2022-04-30'>,'yyyy-mm-dd')
                        and s.jumin = '1861175';                        
--출결관리 및 출결 조회(일)                      
select
    a.attDate as "날짜",
    a.attendance "출결"
from tblStudents s
    inner join tblAtt a
        on s.stuSeq = a.stuSeq
        where a.attDate = '2022-03-19';
            and s.jumin = '1861175';



-- 교육생은 과정에 대한 평가를 조회할 수 있다.

select 
    c.name as “과정명”,
    ev.content “평가내용”,
    s.name “교육생이름”
from
    tblStudents s
        inner join tblEvaluation ev
            on s.stuSeq = ev.stuSeq
                inner join tblApply ap
                    on s.stuSeq = ap.stuSeq
                        inner join tblOpenClass oc
                            on oc.openSeq = ap.openSeq
                                inner join tblClass c
                                    on c.courseSeq = oc.courseSeq;




-- 교육생은 재시험 대상인지 조회할 수 있다.

--재시험 조회
select 
    s.name,
    r.reTestDate,
    sj.name,
    g.writeScore,
    g.pracScore
from tblOpenSub os
    inner join tblGrade g
        on os.openSubSeq = g.openSubSeq
            inner join tblReTest r
                on g.gradeSeq = r.gradeSeq
                    inner join tblSubject sj
                        on sj.subSeq = os.subSeq
                            inner join tblStudents s
                                on s.stuSeq = g.stuSeq
                                    where jumin = '1861175';                        



