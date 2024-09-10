ALTER TABLE owned_vehicles
ADD has_stance TINYINT NOT NULL DEFAULT 0;

ALTER TABLE owned_vehicles
ADD stance_mods json NOT NULL DEFAULT "{}";
-- name, label, weight, rare, can_remove
INSERT INTO items VALUES ('stancekit', 'Stance Kit', 40, 0, 1)