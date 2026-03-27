BEGIN;

--
-- Function: gen_random_uuid_v7()
-- Source: https://gist.github.com/kjmph/5bd772b2c2df145aa645b837da7eca74
-- License: MIT (copyright notice included on the generator source code).
--
create or replace function gen_random_uuid_v7()
returns uuid
as $$
begin
  -- use random v4 uuid as starting point (which has the same variant we need)
  -- then overlay timestamp
  -- then set version 7 by flipping the 2 and 1 bit in the version 4 string
  return encode(
    set_bit(
      set_bit(
        overlay(uuid_send(gen_random_uuid())
                placing substring(int8send(floor(extract(epoch from clock_timestamp()) * 1000)::bigint) from 3)
                from 1 for 6
        ),
        52, 1
      ),
      53, 1
    ),
    'hex')::uuid;
end
$$
language plpgsql
volatile;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "safety_block" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "blockerAuthUserId" uuid NOT NULL,
    "blockedAuthUserId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "safety_block_pair_unique" ON "safety_block" USING btree ("blockerAuthUserId", "blockedAuthUserId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "safety_report" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "reporterAuthUserId" uuid NOT NULL,
    "targetUserId" uuid,
    "targetChatId" text,
    "targetMessageId" text,
    "reason" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "safety_report_reporter_time" ON "safety_report" USING btree ("reporterAuthUserId", "createdAt");


--
-- MIGRATION VERSION FOR chat
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('chat', '20260327161831530', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260327161831530', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260213194423028', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260213194423028', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260129181112269', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129181112269', "timestamp" = now();


COMMIT;
