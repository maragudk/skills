create table entries (
  id text primary key default ('e_' || lower(hex(randomblob(16)))),
  created text not null default (strftime('%Y-%m-%dT%H:%M:%fZ')),
  updated text not null default (strftime('%Y-%m-%dT%H:%M:%fZ')),
  content text not null
) strict;

create trigger entries_updated_timestamp after update on entries begin
  update entries set updated = strftime('%Y-%m-%dT%H:%M:%fZ') where id = old.id;
end;

create index entries_created_idx on entries (created);

create virtual table entries_fts using fts5(
  content,
  content='entries',
  tokenize = porter
);

create trigger entries_ai_fts
after insert on entries
begin
    insert into entries_fts (rowid, content) values (new.rowid, new.content);
end;

create trigger entries_au_fts
after update on entries
begin
  insert into entries_fts (entries_fts, rowid, content) values('delete', old.rowid, old.content);
  insert into entries_fts (rowid, content) values (new.rowid, new.content);
end;

create trigger entries_ad_fts
after delete on entries
begin
  insert into entries_fts (entries_fts, rowid, content) values('delete', old.rowid, old.content);
end;
