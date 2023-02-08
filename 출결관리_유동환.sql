-- 교사가 강의한 과목에 한해 선택하는 경우 모든 교육생의 출결을 조회할 수 있어야한다.
    select os.opensubseq,tech.name, st.name,at.attdate,at.attendance 
        from tblstudents st
            inner join tblatt at
                on st.stuseq = at.stuseq
                    inner join tblgrade gr
                        on st.stuseq = gr.stuseq
                            inner join tblopensub os
                                on gr.opensubseq = os.opensubseq
                                    inner join tblteachers tech
                                        on os.teacherseq = tech.teacherseq
                                            where tech.teacherseq =  1
                                                order by st.stuseq
                                                ;

-- 출결 현황을 기간별(년, 월, 일) 조회할 수 있어야 한다.
     select st.stuseq as "학생번호"
         , st.name as "학생번호"
         , at.attdate as "출결날짜"
         , at.attendance as "근태"
         from tblstudents st
        inner join tblatt at
            on st.stuseq = at.stuseq
                where at.attdate between '2022-04-11' and '2022-07-12'
                    order by at.attdate,st.stuseq;
                    

-- 특정 인원 출결현황조회
 select st.stuseq
    , st.name as "학생이름"
    , ap.openseq as "과정번호"
    , at.attdate as "출결날짜"
    , oc.courseseq as "과정번호"
    , (select name from tblclass cl where cl.courseseq = oc.courseseq) as "과정명"
    from tblstudents st
        inner join tblapply ap
            on st.stuseq = ap.stuseq
                inner join tblopenclass oc
                    on oc.openseq = ap.openseq
                        inner join tblatt at
                            on at.stuseq = st.stuseq
            where st.name = '정다예'
                                order by st.stuseq, oc.courseseq, at.attdate;





-- 특정과정 출결조회                                     
 select 
    oc.courseseq  as "과정번호",
    (select name from tblclass cl where cl.courseseq = oc.courseseq) as "과정명"
    , st.stuseq as "학생번호"
    , st.name  as "학생이름"
    , ap.openseq as "과정번호"
    , at.attdate as "출결날짜"
    
    from tblstudents st
        inner join tblapply ap
            on st.stuseq = ap.stuseq
                inner join tblopenclass oc
                    on oc.openseq = ap.openseq
                        inner join tblatt at
                            on at.stuseq = st.stuseq
            where oc.openseq = 1
                                order by st.stuseq, oc.courseseq, at.attdate;

-- 모든 출결 조회는 근태 상황을 구분할 수 있어야 한다. (정상, 지각, 조퇴, 외출, 병가, 기타) 
select 
    at.attendance as "근태",
        count(*) as "출석구분"
            from tblatt at
             inner join tblstudents st
                on at.stuseq = st.stuseq
                where st.stuseq = 1
            group by at.attendance
                having at.attendance in ('정상','지각','조퇴','외출','병가','기타');

            inner join tblevaluation ev
                on  st.stuseq = ev.stuseq
                    inner join tblapply ap
                        on ap.stuseq = st.stuseq
                            inner join tblopenclass oc
                                on oc.openseq = ap.openseq
                                    inner join tblclass cl
                                        on cl.courseseq = oc.courseseq
                                            where oc.openseq = 1;


-- 교육생, 교사는 게시판에 게시글을 등록할수 있고, 댓글을 작성할수있다.(게시글 등록)
INSERT INTO tblBoard(boardSeq,content,postDate,teacherSeq,stuSeq) VALUES (boardSeq.nextVal, '게시판에 들어갈내용', sysdate , 1  , 1); 

--교육생, 교사는 게시판에 게시글을 등록할수 있고, 댓글을 작성할수있다.(댓글 등록)
INSERT INTO tblComment(commentSeq, content, boardSeq, teacherSeq, stuSeq) VALUES (vseq,pcontent, 1 , 1, 1);

-- 본인이 등록한 게시글은 등록, 수정, 삭제가 가능하다.
delete from tblboard where teacherSeq =1 and boardseq = 1;
delete from tblboard where stuSeq = 1 and boardseq =  1;
update tblboard set content = 1 where boardseq = 1;

-- 교사는 교육생들의 게시글을 조회, 삭제할 수 있다.
select bo.boardseq as "게시판번호"
            , bo.teacherseq as "교사번호"
            , bo.stuseq as "교육생번호"
            , bo.content as "게시내용"
            , co.content as "댓글내용" from tblboard bo 
        inner join tblcomment co
            on bo.boardseq = co.boardseq;



-- 교사는 과정에 대한 평가에 대한 정보를 조회할수 있다.
select cl.name
       , st.name
       ,ev.content from tblstudents st
            inner join tblevaluation ev
                on  st.stuseq = ev.stuseq
                    inner join tblapply ap
                        on ap.stuseq = st.stuseq
                            inner join tblopenclass oc
                                on oc.openseq = ap.openseq
                                    inner join tblclass cl
                                        on cl.courseseq = oc.courseseq
                                            where oc.openseq = 1;



