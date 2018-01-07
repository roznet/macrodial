/* find current ordered macros for profile id  */
select  macro_name FROM macro_current m, profiles_defs p WHERE profile_id = '1' AND p.macro_id = m.macro_id ORDER BY sortorder;
