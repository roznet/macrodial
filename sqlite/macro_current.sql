/* update last use */
UPDATE macro_current SET lastuse = datetime('now') WHERE macro_id = 3;
/* macros by sortorder */
SELECT displayname, definition FROM macro_current ORDER BY sortorder;
/* macros by last user */
SELECT displayname, definition FROM macro_current ORDER BY lastuse DESC;