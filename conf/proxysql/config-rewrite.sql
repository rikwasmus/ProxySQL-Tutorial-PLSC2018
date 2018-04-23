# LOAD query rules for rewrite

DELETE FROM mysql_query_rules;
INSERT INTO mysql_query_rules (rule_id,active,match_digest,destination_hostgroup,apply) VALUES (1,1,'^SELECT.*FOR UPDATE',0,1),(2,1,'^SELECT',1,1);

INSERT INTO mysql_query_rules (rule_id,active,match_pattern,replace_pattern,destination_hostgroup,apply)
          VALUES (3,1,'^select (.*)sensitive_number([ ,])(.*)',
                "SELECT \1CONCAT(REPEAT('X',8),RIGHT(sensitive_number,4)) sensitive_number\2\3",0,1);

LOAD MYSQL QUERY RULES TO RUNTIME;
SAVE MYSQL QUERY RULES TO DISK;

# query rules for mirroring
DELETE FROM mysql_query_rules WHERE rule_id=4;
INSERT INTO mysql_query_rules (rule_id,active,match_pattern,replace_pattern,mirror_flagOUT,apply) VALUES (4,1,'^insert into customer(.*)',"INSERT INTO perconalive.audit (`user_name`, `table_name`) VALUES (USER(), 'customer')",0,1);

LOAD MYSQL QUERY RULES TO RUNTIME;
SAVE MYSQL QUERY RULES TO DISK;
