BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "chat_member" (
    "id" bigserial PRIMARY KEY,
    "chatId" uuid NOT NULL,
    "memberAuthUserId" uuid NOT NULL,
    "role" text NOT NULL,
    "joinedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastReadSeq" bigint NOT NULL DEFAULT 0
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "chat_message" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "chatId" uuid NOT NULL,
    "senderAuthUserId" uuid NOT NULL,
    "senderDeviceId" uuid,
    "serverSeq" bigint NOT NULL,
    "clientMsgId" text NOT NULL,
    "ciphertext" text NOT NULL,
    "nonce" text NOT NULL,
    "schemaVersion" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "chat_thread" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "type" text NOT NULL,
    "title" text,
    "createdByAuthUserId" uuid,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "registered_device" (
    "id" bigserial PRIMARY KEY,
    "deviceId" text NOT NULL,
    "ownerAuthUserId" text NOT NULL,
    "platform" text NOT NULL,
    "name" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastSeenAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- MIGRATION VERSION FOR pod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('pod', '20260327121256774', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260327121256774', "timestamp" = now();

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
