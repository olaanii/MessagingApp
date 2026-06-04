BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "story" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "authorAuthUserId" uuid NOT NULL,
    "mediaType" text NOT NULL,
    "encryptedPayload" text NOT NULL,
    "nonce" text NOT NULL,
    "thumbnailCiphertext" text,
    "privacy" text NOT NULL DEFAULT 'all_contacts',
    "selectedViewerIds" text,
    "expiresAt" timestamp without time zone NOT NULL DEFAULT (now() + interval '24 hours'),
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "story_author_time" ON "story" ("authorAuthUserId", "createdAt");
CREATE INDEX "story_expires_at"  ON "story" ("expiresAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "story_view" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "storyId" uuid NOT NULL,
    "viewerAuthUserId" uuid NOT NULL,
    "viewedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "story_view_story_fk"
      FOREIGN KEY ("storyId") REFERENCES "story" ("id") ON DELETE CASCADE,
    CONSTRAINT "story_view_unique"
      UNIQUE ("storyId", "viewerAuthUserId")
);

CREATE INDEX "story_view_story" ON "story_view" ("storyId");

--
-- MIGRATION VERSION FOR chat
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('chat', '20260530120000000', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260530120000000', "timestamp" = now();

COMMIT;
