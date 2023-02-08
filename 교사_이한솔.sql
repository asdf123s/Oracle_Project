-- team4_교사_이한솔.sql

set serveroutput on;

/*
    강의 스케쥴 조회
    1. 과목번호 > 개설과목(tblOpenSub) , 과정명, 과정기간(시작 년월일 / 끝 년월일),
      강의실, 과목명, 과목기간, 교재명, 교육생 등록 인원
    - 교육생 정보 (교육생 이름, 전화번호, 등록일, 수료 또는 중도탈락)
    - 강의 진행 상태 > 날짜 기준
*/

-- 1. 강의 목록
create or replace procedure procSchedule (
    vSeq in number,
    pcursor out sys_refcursor
) is begin
    open pcursor
        for
        select s.subSeq, c.name, oc.startdate, oc.enddate, cr.name, s.name, os.startdate, os.enddate, b.bookName, count(*)
    from tblteachers t
        left outer join tblOpenSub os
            on t.teacherSeq = os.teacherseq
             inner join tblSubject s
                on os.subSeq = s.subSeq
                    inner join tblClassSub cs
                        on s.subSeq = cs.subSeq
                            inner join tblClass c
                                on cs.courseSeq = c.courseSeq
                                    inner join tblopenclass oc
                                        on c.courseSeq = oc.courseSeq
                                            inner join tblClassRoom cr
                                                on oc.classroomSeq = cr.classroomseq
                                                    left outer join tblApply a
                                                        on oc.openSeq = a.openSeq
                                                            inner join tblBook b
                                                                on s.bookSeq = b.bookSeq 
    where t.teacherSeq = vSeq
            group by a.openSeq, c.name, s.subSeq, cr.name, s.name, b.Bookname, oc.startdate, oc.enddate, os.startdate, os.enddate
                order by s.subSeq;
end procSchedule;        

-- 프로시저 호출
declare
    vcursor SYS_REFCURSOR;
    vSubSeq tblSubject.subSeq%type;
    vClassName tblClass.name%type;
    vClassStart tblOpenClass.startdate%type;
    vClassEnd tblOpenClass.enddate%type;
    vRoom tblClassRoom.name%type;
    vSubName tblSubject.name%type;
    vSubStart tblOpenSub.startdate%type;
    vSubEnd tblOpenSub.enddate%type;
    vBook tblBook.bookname%type;
    vCount number;
begin
    procSchedule(2, vcursor);

    loop
        fetch vcursor into  vsubSeq, vClassName, vClassStart, vClassEnd, vRoom, vSubName, vSubStart, vSubEnd, vBook, vCount;
        exit when vcursor%notfound;
        
        dbms_output.put_line('과목번호 : ' || vsubSeq || '  |  ' || '과정명 : ' || vClassName || '  |  ' || '과정기간 : ' || vClassStart || ' - ' || vClassEnd || '  |  ' || '강의실 : ' || vRoom || '   ' || 
        '과목명 : ' || vSubName || '  |  ' || '과목기간 : ' || vSubStart || ' - ' || vSubEnd || '  |  ' || '교재명 : ' || vBook || '  |  ' || '교육생 등록 인원 : ' || vCount);
    end loop;
    close vcursor;
end;



-- 교육생 정보 (교육생 이름, 전화번호, 등록일, 수료 또는 중도탈락)
create or replace procedure procStu (
    vSeq in number,
    pcursor out sys_refcursor
)
is begin
    open pcursor
        for
select
    st.name,
    st.tel,
    st.regdate,
    st.enddate,
    st.fail
from tblteachers t inner join tblopensub os on os.teacherSeq = t.teacherseq 
    inner join tblclassopen co
        on co.opensubseq = os.opensubseq
            inner join tblopenclass oc
                on oc.openseq = co.openseq
                    inner join tblapply a
                        on a.openseq = oc.openseq
                            inner join tblstudents st
                                on st.stuseq = a.stuseq                              
where t.teacherseq = vseq
group by st.name, st.tel, st.regdate, st.enddate, st.fail;
end procStu;



-- 프로시저 호출
declare
    vcursor SYS_REFCURSOR;
    vName tblStudents.name%type;
    vtel tblStudents.tel%type;
    vsign date;
    vend date;
    vfail tblStudents.fail%type;
begin
    procStu(1, vcursor);
    loop
        fetch vcursor into  vName, vtel, vsign, vend, vfail;
        exit when vcursor%notfound;
    if vfail is null then
        if vend is null then
            dbms_output.put_line('교육생 이름 : ' || vName || '  |  ' || 
                                    '전화번호 : ' || vtel || '  |  ' ||
                                    '등록일 : ' || vsign || '  |  ' ||
                                    '수료일 : ' || 'null' );
        else
            dbms_output.put_line('교육생 이름 : ' || vName || '  |  ' || 
                                    '전화번호 : ' || vtel || '  |  ' ||
                                    '등록일 : ' || vsign || '  |  ' ||
                                    '수료일 : ' || vend  );
        end if;
    else 
        dbms_output.put_line('교육생 이름 : ' || vName || '  |  ' || 
                                    '전화번호 : ' || vtel || '  |  ' ||
                                    '등록일 : ' || vsign || '  |  ' ||
                                    '중도탈락여부 : ' || vfail);
    end if;
        end loop;
        close vcursor;
end;







/*
    배점 입출력
    1. 강의를 마친 과목의 목록 > 특정과목 >
        배점 정보( 출결, 필기, 실기로 구분)
        시험날짜, 시험문제 추가
    2. 과목 목록 출력
        - 과목번호, 과정명, 과정기간, 강의실, 과목명, 과목기간,
          교재명, 출결, 필기, 실기 배점
    3. 특정 과목번호 선택시
        출결 배점, 필기 배점, 실기 배점, 시험날짜, 시험문제
        입력 화면
*/

-- 강의 마친 과목 목록
select 
    s.name,
    os.enddate,
    os.opensubseq
from tblteachers t
    inner join tblopensub os
        on t.teacherSeq = os.teacherSeq
            inner join tblsubject s
                on os.subSeq = s.subSeq
where t.teacherSeq = 1 and os.enddate < sysdate;


-- 특정 과목
select 
    s.name as "과목",
    p.attendance as "출결",
    p.write as "필기",
    p.practice as "실기"
from tblteachers t
    inner join tblopensub os
        on t.teacherSeq = os.teacherSeq
            inner join tblsubject s
                on os.subSeq = s.subSeq
                    inner join tblPoint p
                        on p.pointSeq = os.pointSeq
where t.teacherSeq = 1 and os.opensubseq = 1;



-- 배점 입력 (출결, 필기, 실기)
-- 배점 등록 안된 과목은 null로 출력
create or replace procedure procInsPoint (
    vnum number,        -- 배점번호
    vatt tblpoint.attendance%type,  -- 출결
    vwrite tblpoint.write%type,         -- 필기
    vpract tblpoint.practice%type      -- 실기
)
is
begin
    update tblpoint set attendance = vatt, write = vwrite, practice = vpract where pointseq = vnum;
end procInsPoint;

-- 확인
begin
    procInsPoint(1, 15, 35, 50);
end;

select * from tblpoint where pointSeq = 1;



-- 시험날짜 (필기)
create or replace procedure procWExam (
    vos number,
    vtdate date
)
is
    vts number;
begin
    select w.testseq into vts from tblopensub os right outer join tblwtest w on os.opensubseq = w.opensubseq where os.opensubseq = vos;
    
    update tblwtest set testdate = vtdate where testseq = vts;
end procWExam;

-- 확인
begin
    procWExam(1, '2022-01-20');
end;

select * from tblwtest where opensubseq = 1;


-- 시험문제
create or replace procedure procWQuestion (
    vos number,
    vqnum number,
    vquestion tblwriteQ.question%type
)
is
    vqs number;
    vts number;
begin
    
    select w.testseq into vts from tblopensub os right outer join tblwtest w on os.opensubseq = w.opensubseq where os.opensubseq = vos;
    
    vqs := writeSeq.nextVal;
    insert into tblwriteq values (vqs, vqnum, vquestion, vts);
end procWQuestion;

-- 확인
begin
    procWQuestion(1, 6, '메소드에 대해 서술하시오.');
end;

select * from tblwriteq where testseq = 1;



-- 시험날짜(실기)
create or replace procedure procPExam (
    vos number,
    vtdate date
)
is
    vts number;
begin
    select p.testseq into vts from tblopensub os right outer join tblptest p on os.opensubseq = p.opensubseq where os.opensubseq = vos;
    
    update tblptest set testdate = vtdate where testseq = vts;
end procPExam;

-- 확인
begin
    procPExam(1, '2022-01-28');
end;

select * from tblptest where opensubseq = 1;

-- 시험문제
create or replace procedure procPQuestion (
    vos number,
    vqnum number,
    vquestion tblpracticeQ.question%type
)
is
    vqs number;
    vts number;
begin
    
    select p.testseq into vts from tblopensub os right outer join tblptest p on os.opensubseq = p.opensubseq where os.opensubseq = vos;
    
    vqs := PractSeq.nextVal;
    insert into tblpracticeq values (vqs, vqnum, vquestion, vts);
end procPQuestion;

-- 확인
begin
    procPQuestion(1, 6, 'if문을 사용하여 결과를 출력하시오.');
end;

select * from tblpracticeq where testseq = 1;








/*
    성적 입출력
    1. 강의를 마친 과목의 목록 > 특정 과목 선택 > 교육생 정보
        > 교육생 정보 선택 > 해당 교육생의 시험 점수 입력
        출결, 필기, 실기 점수 구분 입력
    2. 과목 목록 출력 
        - 과목번호 | 과정명 | 과정기간 | 강의실 | 과목명 | 과목기간 | 교재명 | 출결 / 필기 / 실기 배점
    3. 특정 과목 선택
        - 교육생 정보
        - 이름 | 전화번호 | 수료 / 중도탈락 | 출결 / 필기 / 실기 점수 | 과락 여부
*/
-- 강의 마친 과목 목록
create or replace procedure procEndSub (
    vSeq in number,
    pcursor out sys_refcursor
)
is
begin
    open pcursor
        for
        select
        s.subSeq,
        c.name,
        oc.startdate,
        oc.enddate,
        cr.name,
        s.name,
        os.startdate,
        os.enddate,
        b.bookName,
        count(*),
        p.attendance,
        p.write,
        p.practice
    from tblteachers t
        inner join tblOpenSub os
            on t.teacherSeq = os.teacherseq
             inner join tblSubject s
                on os.subSeq = s.subSeq
                    inner join tblClassSub cs
                        on s.subSeq = cs.subSeq
                            inner join tblClass c
                                on cs.courseSeq = c.courseSeq
                                    inner join tblopenclass oc
                                        on c.courseSeq = oc.courseSeq
                                            inner join tblClassRoom cr
                                                on oc.classroomSeq = cr.classroomseq
                                                    inner join tblApply a
                                                        on oc.openSeq = a.openSeq
                                                            inner join tblBook b
                                                                on s.bookSeq = b.bookSeq
                                                                    inner join tblpoint p
                                                                        on p.pointseq = os.pointseq
    where t.teacherSeq = vSeq and os.enddate < sysdate
            group by a.openSeq, c.name, s.subSeq, cr.name, s.name, b.Bookname, oc.startdate, oc.enddate, os.startdate, os.enddate, p.attendance, p.write, p.practice
                order by s.subSeq;
end procEndSub;        


declare
    vcursor SYS_REFCURSOR;
    vSubSeq tblSubject.subSeq%type;
    vClassName tblClass.name%type;
    vClassStart tblOpenClass.startdate%type;
    vClassEnd tblOpenClass.enddate%type;
    vRoom tblClassRoom.name%type;
    vSubName tblSubject.name%type;
    vSubStart tblOpenSub.startdate%type;
    vSubEnd tblOpenSub.enddate%type;
    vBook tblBook.bookname%type;
    vCount number;
    vAtt number;
    vWrite number;
    vPract number;
begin
    procEndSub(1, vcursor);

    loop
        fetch vcursor into  vsubSeq, vClassName, vClassStart, vClassEnd, vRoom, vSubName, vSubStart, vSubEnd, vBook, vCount, vAtt, vWrite, vPract;
        exit when vcursor%notfound;
        
        dbms_output.put_line('과목번호 : ' || vsubSeq || '  |  ' || '과정명 : ' || vClassName || '  |  ' || '과정기간 : ' || vClassStart || ' - ' || vClassEnd || '  |  ' || '강의실 : ' || vRoom || '   ' || 
        '과목명 : ' || vSubName || '  |  ' || '과목기간 : ' || vSubStart || ' - ' || vSubEnd || '  |  ' || '교재명 : ' || vBook || '  |  ' || '교육생 등록 인원 : ' || vCount || '  |  ' ||
        '출결 : ' || vAtt || '  |  ' || '필기 : ' || vWrite || '  |  ' || '실기 : ' || vPract );
    end loop;
    close vcursor;
end;



-- 특정 과목 선택시 교육생 정보 출력
-- 이름 | 전화번호 | 수료 / 중도탈락 | 출결 / 필기 / 실기 점수 | 과락 여부
create or replace procedure procScore (
    vSeq in number,
    vos number,
    pcursor out sys_refcursor
)
is begin
    open pcursor
        for
            select
                st.name,
                st.tel,
                st.enddate,
                st.fail,
                g.attscore,
                g.writescore,
                g.pracscore,
                g.retest,
                f.faildate
            from tblteachers t
                inner join tblOpenSub os
                    on t.teacherSeq = os.teacherseq
                     inner join tblSubject s
                        on os.subSeq = s.subSeq
                            inner join tblClassSub cs
                                on s.subSeq = cs.subSeq
                                    inner join tblClass c
                                        on cs.courseSeq = c.courseSeq
                                            inner join tblopenclass oc
                                                on c.courseSeq = oc.courseSeq
                                                    inner join tblClassRoom cr
                                                        on oc.classroomSeq = cr.classroomseq
                                                            inner join tblApply a
                                                                on oc.openSeq = a.openSeq
                                                                    inner join tblStudents st
                                                                        on st.stuSeq = a.stuSeq
                                                                            right outer join tblgrade g
                                                                                on g.stuseq = st.stuseq
                                                                                    left outer join tblfail f
                                                                                        on st.stuseq = f.stuseq
                where t.teacherSeq = 1 and os.opensubseq = 1;
end procScore;

-- 이름 | 전화번호 | 수료 / 중도탈락 | 출결 / 필기 / 실기 점수 | 과락 여부
declare
    vcursor SYS_REFCURSOR;
    vName tblStudents.name%type;
    vtel tblStudents.tel%type;
    vend date;
    vfail tblStudents.fail%type;
    vatt number;
    vwrite number;
    vpract number;
    vretest tblgrade.retest%type;
    vfdate tblfail.faildate%type;
begin
    procScore(1, 1, vcursor);
    
    loop
        fetch vcursor into  vName, vtel, vend, vfail, vatt, vwrite, vpract, vretest, vfdate;
        exit when vcursor%notfound;
   
    if vfail is null then
    
        if vend is null then
            dbms_output.put_line('교육생 이름 : ' || vName || '  |  ' || 
                                        '전화번호 : ' || vtel || '  |  ' ||
                                        '중도탈락여부 : ' || 'null' || '  |  ' ||
                                        '수료일 : ' || 'null' || '  |  '|| 
                                        '출결 : ' || vatt || '  |  ' || 
                                        '필기 : ' || vwrite || '  |  ' || 
                                        '실기 : ' || vpract || '  |  ' ||
                                        '과락여부 : ' || vretest || '  |  ' );
        else
            dbms_output.put_line('교육생 이름 : ' || vName || '  |  ' || 
                                        '전화번호 : ' || vtel || '  |  ' ||
                                        '중도탈락여부 : ' || 'null' || '  |  ' ||
                                        '수료일 : ' || vend || '  |  '|| 
                                        '출결 : ' || vatt || '  |  ' || 
                                        '필기 : ' || vwrite || '  |  ' || 
                                        '실기 : ' || vpract || '  |  ' ||
                                        '과락여부 : ' || vretest || '  |  ' );
        end if;                                    
    
    else 
        dbms_output.put_line('교육생 이름 : ' || vName || '  |  ' || 
                                        '전화번호 : ' || vtel || '  |  ' ||
                                        '중도탈락여부 : ' || vfail || '  |  ' ||
                                        '중도탈락일 : ' || vfdate || '  |  ' ||
                                        '수료일 : ' || 'null' || '  |  '|| 
                                        '출결 : ' || 'null' || '  |  ' || 
                                        '필기 : ' || 'null' || '  |  ' || 
                                        '실기 : ' || 'null' || '  |  ' ||
                                        '과락여부 : ' || 'null' || '  |  ' );
    end if;
        end loop;
        close vcursor;
end;



--select
--                st.name,
--                st.tel,
--                st.enddate,
--                st.fail
--                g.attscore,
--                g.writescore,
--                g.pracscore,
--                g.retest
--                f.faildate
--            from tblteachers t
--                inner join tblOpenSub os
--                    on t.teacherSeq = os.teacherseq
--                     inner join tblSubject s
--                        on os.subSeq = s.subSeq
--                            inner join tblClassSub cs
--                                on s.subSeq = cs.subSeq
--                                    inner join tblClass c
--                                        on cs.courseSeq = c.courseSeq
--                                            inner join tblopenclass oc
--                                                on c.courseSeq = oc.courseSeq
--                                                    inner join tblClassRoom cr
--                                                        on oc.classroomSeq = cr.classroomseq
--                                                            inner join tblApply a
--                                                                on oc.openSeq = a.openSeq
--                                                                    inner join tblStudents st
--                                                                        on st.stuSeq = a.stuSeq
--                                                                            left outter join tblgrade g
--                                                                                on g.stuseq = st.stuseq
--                                                                                    left outer join tblfail f
--                                                                                        on st.stuseq = f.stuseq
--                where t.teacherSeq = 1 and os.opensubseq = 1;
--                    and st.name = '전정현';



select * from tblStudents where name = '김민환';
select * from tblStudents where stuSEq = 24;
select * from tblFail where stuSeq = 161;





 -- 성적입력
 -- 과목번호 | 교사번호 | 학생번호 | 출결점수 | 필기점수 | 실기점수
 -- 필기 실기 60점 이하면 재시험
 
 /*
    교사번호 : 1
    학생번호 : 1
    과목번호 : 1
 */
 
 -- 배점 확인
 select * from tblpoint where pointseq = 1;
 
 -- 과목 시작날짜 / 과목 끝날짜 추출
select startdate, enddate from tblopensub where opensubseq = 1;

-- 과목 전체출결 갯수
-- startdate : 22/01/07     |       enddate : 22/01/27
-- 총 수업일 : 13일
select count(*) from tblatt where stuseq = 1 and attendance in ('정상', '결석', '지각', '조퇴', '외출') and attdate between '2022-01-07' and '2022-01-27';
    
-- 과목 결석 갯수
-- 결석 : 0개
select count(*) from tblatt where stuseq = 1 and attendance = '결석' and attdate between '2022-01-07' and '2022-01-27';
    
-- 과목 지각 | 조퇴 | 외출 갯수
-- 1개
select count(*) from tblatt where stuseq = 1 and attendance in ('지각', '조퇴', '외출') and attdate between '2022-01-07' and '2022-01-27';

-- 20 / 13
select round(20 / 13, 1) as "배점" from dual;   -- 1.5점

-- 필기, 1개 틀림
select * from tblwtest where opensubseq = 1;
select * from tblwriteq where testseq = 1; -- 5문제
select 30/5 as 배점 from dual;    -- 6점

-- 실기, 2개 틀림
select * from tblptest where opensubseq = 1;
select * from tblpracticeq where testseq = 1; -- 5문제
select 50/5 as 배점 from dual;    -- 10점

-- 총 점수
-- 19.5     |      24       |       30          
select 1.5 * 13 as 출결, 6 * 4 as 필기, 10 * 3 as 실기 from dual;

    


 
create or replace procedure procInsScore (
    vos number,
    vss number,
    vatt number,
    vwrite number,
    vprac number
)
is
begin
    
    if vwrite < 60 or vprac < 60 then
        insert into tblgrade (gradeseq, attscore, writescore, pracscore, retest, opensubseq, stuseq) values (gradeseq.nextVal, vatt, vwrite, vprac, '불합격', vos, vss);
    else
        insert into tblgrade (gradeseq, attscore, writescore, pracscore, retest, opensubseq, stuseq) values (gradeseq.nextVal, vatt, vwrite, vprac, '통과', vos, vss);
    end if;
    
end procInsScore;


begin
    procInsScore(1, 1, 18, 55, 60);
end;
    

