-- Jalankan sekali di SQL Editor proyek Supabase BARU untuk mantest scode.
create table if not exists public.mantest_members(email text primary key, name text not null, role text not null check(role in ('Admin','Tester','Developer')));
create table if not exists public.mantest_records(id text primary key, kind text not null check(kind in ('case','run','bug','cycle','project','decision')),payload jsonb not null);
create or replace function public.mantest_role() returns text language sql stable security definer set search_path=public as $$ select role from public.mantest_members where email=lower(auth.jwt()->>'email') $$;
revoke all on function public.mantest_role() from public;
grant execute on function public.mantest_role() to authenticated;
alter table public.mantest_members enable row level security;
alter table public.mantest_records enable row level security;
create policy members_read on public.mantest_members for select to authenticated using(public.mantest_role() is not null);
create policy members_write on public.mantest_members for all to authenticated using(public.mantest_role()='Admin') with check(public.mantest_role()='Admin');
create policy records_read on public.mantest_records for select to authenticated using(public.mantest_role() is not null);
create policy records_insert on public.mantest_records for insert to authenticated with check(public.mantest_role()='Admin' or (public.mantest_role()='Tester' and kind in ('run','bug')) or (public.mantest_role()='Developer' and kind='bug'));
create policy records_update on public.mantest_records for update to authenticated using((public.mantest_role()='Admin' and kind<>'run') or (public.mantest_role() in ('Tester','Developer') and kind='bug')) with check((public.mantest_role()='Admin' and kind<>'run') or (public.mantest_role() in ('Tester','Developer') and kind='bug'));
create or replace function public.mantest_validate() returns trigger language plpgsql set search_path=public as $$
begin
 if TG_OP='UPDATE' and (OLD.kind='run' or NEW.kind<>OLD.kind) then raise exception 'Riwayat eksekusi tidak dapat ditimpa'; end if;
 if NEW.payload->>'project' is null then raise exception 'Proyek wajib';end if;
 if NEW.kind='run' then
  if NEW.payload->>'status' not in ('Belum diuji','Lulus','Gagal','Terblokir','Tidak berlaku') then raise exception 'Status tidak valid';end if;
  if NEW.payload->>'status'<>'Belum diuji' and (coalesce(NEW.payload->>'actual','')='' or coalesce(NEW.payload->>'build','')='' or coalesce(NEW.payload->>'evidence','')='' or coalesce(NEW.payload->>'environment','')='') then raise exception 'Hasil, build, lingkungan dan bukti wajib';end if;
  if NEW.payload->>'status'='Gagal' and not exists(select 1 from public.mantest_records where kind='bug' and id=NEW.payload->>'bugId') then raise exception 'Hubungkan bug yang valid';end if;
  if NEW.payload->>'status' in ('Terblokir','Tidak berlaku') and coalesce(NEW.payload->>'reason','')='' then raise exception 'Alasan wajib';end if;
 end if;
 if NEW.kind='bug' and NEW.payload->>'status'='Ditutup' and public.mantest_role()='Developer' then raise exception 'Tester menutup bug setelah retest';end if;
 if NEW.kind='bug' and NEW.payload->>'status'='Ditutup' and not exists(select 1 from public.mantest_records r where r.kind='run' and r.id=NEW.payload->>'retestRun' and r.payload->>'status'='Lulus' and r.payload->>'bugId'=NEW.id) then raise exception 'Penutupan membutuhkan retest lulus yang terhubung ke bug';end if;
 NEW.payload=NEW.payload||jsonb_build_object('by',auth.jwt()->>'email','at',now());return NEW;
end $$;
create trigger mantest_validate_record before insert or update on public.mantest_records for each row execute function public.mantest_validate();
grant select,insert,update on public.mantest_members to authenticated;
grant select,insert,update on public.mantest_records to authenticated;
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types) values('mantest-evidence','mantest-evidence',false,5242880,array['image/png','image/jpeg','image/webp','application/pdf']) on conflict(id) do nothing;
create policy evidence_read on storage.objects for select to authenticated using(bucket_id='mantest-evidence' and public.mantest_role() is not null);
create policy evidence_upload on storage.objects for insert to authenticated with check(bucket_id='mantest-evidence' and public.mantest_role() in ('Admin','Tester'));
-- Setelah menjalankan schema, tambahkan ADMIN PERTAMA dengan email Anda:
-- insert into public.mantest_members(email,name,role) values('emailanda@example.com','Nama Anda','Admin');
