DO $$
  DECLARE
    diagnosiscode_read record;
    category_read record;
    codex_record record;
    conditionlistversion_read record;
    conditionlist_id int;
    conditionlistversion_id int;
  BEGIN
    INSERT INTO conditionlist.conditionlist(id, sfid)
    VALUES (nextval('conditionlist.conditionlistseq'), MD5(random()::text)) RETURNING id INTO conditionlist_id;
    
    INSERT INTO conditionlist.conditionlistversion(id, sfid, condition_id, effectivedate, enddate, url)
    VALUES (nextval('conditionlist.conditionlistversionseq'), MD5(random()::text), conditionlist_id, NOW(), NOW() + INTERVAL '100 day', MD5(random()::text)) RETURNING id INTO conditionlistversion_id;

    FOR codex_record IN 
      (
        SELECT 
          c.id as condition_id,
          c.code as condition_code,
          c.name as condition_name,
          cg.id as conditiongroup_id,
          cg.name as conditiongroup_name,
          cg.orderindex as conditiongroup_orderindex,
          cg.columnindex as conditiongroup_columnindex
        FROM codex.conditiongroup cg
        JOIN codex.condition c on c.conditiongroup_id = cg.id    
      )
    LOOP
    
      SELECT * FROM conditionlist.diagnosiscode WHERE conditionlist.diagnosiscode.code = codex_record.condition_code INTO diagnosiscode_read;
      IF NOT FOUND THEN
        RAISE EXCEPTION '% cannot be found in conditionlist.diagnosiscode', codex_record.condition_code;
      END IF;

      SELECT * FROM conditionlist.category WHERE conditionlist.category.name = codex_record.conditiongroup_name INTO category_read;
      IF NOT FOUND THEN
        RAISE EXCEPTION '% cannot be found in conditionlist.category', codex_record.condition_name;
      END IF;

      INSERT INTO conditionlist.conditionlistversiondetail(id, sfid, diagnosiscode_id, conditioncategory_id, conditionlistversion_id)
      VALUES (nextval('conditionlist.conditionlistversiondetailseq'), MD5(random()::text) , diagnosiscode_read.id, category_read.id, conditionlistversion_id);

    END LOOP;
  END $$;

  