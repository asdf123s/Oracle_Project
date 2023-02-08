-- Team4.sql


drop table tblSAnswer;
drop table tblTAnswer;
drop table tblTBoard;
drop table tblSBoard;
drop table tblWriteQ;
drop table tblPracticeQ;
drop table tblWTest;
drop table tblPTest;
drop table tblReTest;
drop table tblGrade;
drop table tblEvaluation;
drop table tblFail;
drop table tblStudentEmp;
drop table tblClassEmp;
drop table tblAtt;
drop table tblStudents;
drop table tblMap;
drop table tblOpenSub;
drop table tblPossible;
drop table tblSubject;
drop table tblOpenClass;

drop table tblHoliday;
drop table tblBook;
drop table tblPoint;
drop table tblClassRoom;
drop table tblTeachers;
drop table tblClass;
drop table tblAdmin;


--------------- Create Table -----------------------------------------------------------
-- 총 26개

-- 1. 관리자, tblAdmin
create table tblAdmin ( 
    seq number primary key,     -- 관리자번호
    name varchar2(50) not null, -- 이름
    jumin varchar2(50) not null -- 주민번호 뒷자리
);

-- 2. 과정,  tblClass
create table tblClass (
    courseSeq number primary key,   -- 과정번호
    name varchar2(100) not null     -- 과정명
);

-- 3. 교사 테이블,  tblTeachers
create table tblTeachers(
    teacherSeq number primary key,          --교사 번호
    name varchar2(50) not null,            --교사 이름
    jumin varchar2(50) not null,           --주민번호 뒷자리
    tel varchar2(50) not null,               --전화번호
    schedule varchar2(50) not null           --스케줄
);

-- 4. 강의실, tblClassRoom
create table tblClassRoom(
    classRoomSeq number primary key,        --강의실 번호
    name varchar2(30) not null,             --강의실 이름
    stuLimit number not null                -- 정원
);

-- 5. 배점,  tblPoint
create table tblPoint (
    pointSeq number primary key,    --  배점번호
    attendance number,                  -- 출결
    write number,                          -- 필기
    practice number                       -- 실기
);

-- 6. 교재,  tblBook
create table tblBook (
    bookSeq number primary key,            -- 교재번호
    bookName varchar2(100) not null,       -- 교재명
    pubName varchar2(100) not null         -- 출판사명
);

-- 7. 공휴일,  tblHoliday
create table tblHoliday (
    holidaySeq number primary key,  -- 공휴일번호
    regDate date not null,          -- 날짜
    name varchar2(50) not null      -- 공휴일명
);

-- 8. 개설과정
create table tblOpenClass (
    openSeq number primary key,
    startDate date not null,
    endDate date not null,
    courseMonth varchar2(30) not null,
    stuLimit number not null,
    courseSeq number not null references tblClass(courseSeq),
    classRoomSeq number not null references tblClassRoom(classRoomSeq)  
);

-- 9. 과정별 과목
create table tblClassSub (
    classSubSeq number primary key,     -- 과정별 과복 번호(PK)
    subSeq number not null references tblSubject(subSeq),    -- 과목번호(FK)
    courseSeq number not null references tblClass(courseSeq)     -- 과정번호(FK)
);

-- 10. 수강신청
create table tblApply (
    applySeq number primary key,        -- 수강신청 번호(PK)
    stuSeq number not null references tblStudents(stuSeq),   -- 교육생번호(FK)
    openSeq number not null references tblOpenClass(openSeq)
);

-- 11. 교육생별 취업현황
create table tblStudentEmp (
    employmentSeq number primary key,       -- 교육생취업번호(PK)
    employNow varchar2(30) not null,                     -- 취업현황
    employDate date,                               -- 취업날짜
    company varchar2(100),                       -- 취업한 회사명
    stuSeq number not null references tblStudents(stuSeq),   -- 교육생번호(FK)
    courseSeq number not null references tblClass(courseSeq)     -- 과정번호(FK)
);

-- 12. 과목
create table tblSubject (
    subSeq number primary key,      -- 과목번호(PK)
    name varchar2(50) not null,         -- 과목명
    bookSeq number not null references tblBook(bookSeq)      -- 교재번호(FK)
);


-- 13. 강의 가능 과목
create table tblPossible (
    possibleSeq number primary key,                                 -- 강의 가능 과목번호
    subSeq number not null references tblSubject(subSeq),           -- 과목번호
    teacherSeq number not null references tblTeachers(teacherSeq)   -- 교사번호
);

-- 14. 재시험
create table tblReTest (
    reTestSeq number primary key,       -- 재시험번호
    type varchar2(20) not null,              -- 재시험유형
    reTestDate date not null,               -- 재시험날짜
    gradeSeq number not null references tblGrade(gradeSeq)  -- 성적번호
);

-- 15. 개설 과목
create table tblOpenSub (
    openSubSeq number primary key,                                  -- 개설 과목번호
    startDate date,                                                 -- 과목 시작기간
    endDate date,                                                   -- 과목 끝기간
    subSeq number not null references tblSubject(subSeq),           -- 과목번호
    teacherSeq number not null references tblTeachers(teacherSeq),  -- 교사번호
    pointSeq number not null references tblPoint(pointSeq)           -- 배점번호
);

-- 16. 교육생 
create table tblStudents (
    stuSeq number primary key,                   -- 교육생 번호
    name varchar2(50) not null,                  -- 교육생 이름
    jumin varchar2(30) not null,                 -- 주민등록번호 뒷자리
    tel varchar2(30) not null,                   -- 전화번호
    regDate date not null,                       -- 등록일 
    fail varchar2(30),                           -- 중도탈락 여부
    endDate date                                 -- 수료 날짜
);

-- 17. 출결
create table tblAtt (
    attendanceSeq number primary key,                       -- 출결 번호
    attendance varchar2(20) not null,                       -- 근태
    attDate date not null,                                  -- 날짜
    stuSeq number references tblStudents(stuSeq) not null   -- 교육생 번호
);

-- 18. 강의 평가
create table tblEvaluation (
    evaluationSeq number primary key,                       -- 강의평가 번호
    content varchar2(1000) not null,                        -- 강의평가 내용
    stuSeq number references tblStudents(stuSeq) not null   -- 교육생 번호
);

-- 19. 중도 탈락
create table tblFail (
    failSeq number primary key,                             -- 중도탈락 번호
    failDate date not null,                                 -- 중도탈락 날짜
    stuSeq number references tblStudents(stuSeq) not null   -- 교육생 번호
);


-- 20. 전체필기시험
create table tblWTest (
    testSeq number primary key,                                     -- 필기시험번호
    testName varchar2(50) not null,                                 -- 시험 이름
    testDate date not null,                                         -- 시험 날짜
    openSubSeq number not null references tblOpenSub(openSubSeq)    -- 개설과목번호
);

-- 21. 전체실기시험
create table tblPTest (
    testSeq number primary key,                                     -- 실기시험번호
    testName varchar2(50) not null,                                 -- 시험 이름
    testDate date not null,                                         -- 시험 날짜
    openSubSeq number not null references tblOpenSub(openSubSeq)    -- 개설과목번호
);

-- 22. 필기시험문제
create table tblWriteQ (
    questionSeq number primary key,                                 -- 필기시험문제번호
    qNum number not null,                                           -- 문제번호
    question varchar2(1000) not null,                               -- 필기시험문제
    testSeq number not null references tblWTest(testSeq)            -- 필기시험번호
);

-- 23. 실기시험문제
create table tblPracticeQ (
    questionSeq number primary key,                                 -- 실기시험문제번호
    qNum number not null,                                           -- 문제번호
    question varchar2(1000) not null,                               -- 실기시험문제
    testSeq number not null references tblPTest(testSeq)            -- 실기시험번호
);


-- 24. 게시판
create table tblBoard(
    boardSeq number primary key,                                    --게시판번호 
    content varchar2(4000) default '내용없음' not null ,             --게시내용                  --게시내용
    postDate date default sysdate not null ,                        --게시일자
    teacherSeq number  null references tblTeachers(teacherSeq),     --교사번호
    stuSeq number null references tblStudents(stuSeq)               --학생번호
);

-- 25. 게시판답변
create table tblComment(
    commentSeq number primary key,                               --댓글번호
    content varchar2(4000) not null,                            --댓글내용
    boardSeq number not null references tblBoard(boardSeq),     --게시판번호(FK)
    teacherSeq number  null references tblTeachers(teacherSeq),  --교사번호(FK)
    stuSeq number null references tblStudents(stuSeq)           --교육생번호(FK)      
);

-- 26. 성적
create table tblGrade (
    gradeSeq number primary key,        -- 성적번호(PK)
    attScore number,                         -- 출결점수
    writeScore number,                       -- 필기점수
    pracScore number,                        -- 실기점수
    reTest varchar2(50),                     -- 재시험여부
    openSubSeq number not null,              -- 개설과목번호(FK)
    stuSeq number not null,                  -- 교육생번호(FK)

    constraint tblGrade_openSubSeq_fk foreign key(openSubSeq) references tblOpenSub(openSubSeq),
    constraint tblGrade_stuSeq_fr foreign key(stuSeq) references tblStudents(stuSeq)
);

-- 27. 과정별 과목(Open)
create table tblClassOpen (
    classOpenSeq number primary key,                                -- 번호(PK)
    openSeq number not null references tblOpenClass(openSeq),       -- 개설과정번호(FK)
    openSubSeq number not null references tblOpenSub(openSubSeq)    -- 개설과목번호(FK)
);


commit;

