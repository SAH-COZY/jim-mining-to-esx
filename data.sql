INSERT INTO `items` (`name`, `label`, `weight`) VALUES
    ('water_bottle', 'Water Bottle', 1),
    ('sandwich', 'Sandwich', 1),
    ('bandage', 'Bandage', 1),
    ('weapon_flashlight', 'Flashlight', 1),
    ('goldpan', 'Gold pan', 1),
    ('pickaxe', 'Pickaxe', 1),
    ('miningdrill', 'Mining Drill', 1),
    ('mininglaser', 'Mining Laser', 1),
    ('drillbit', 'Drill Bit', 1);

INSERT INTO `jobs` (`name`, `label`) VALUES
    ('miner', 'Miner');

INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`) VALUES
    ('miner', 0, 'worker', 'Worker', 5);