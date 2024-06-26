-- Создание базы данных
CREATE DATABASE IF NOT EXISTS StarObservatory;
USE StarObservatory;

-- Создание таблицы Sector
CREATE TABLE IF NOT EXISTS Sector (
    id INT AUTO_INCREMENT PRIMARY KEY,
    coordinates VARCHAR(255) NOT NULL,
    light_intensity FLOAT NOT NULL,
    foreign_objects INT DEFAULT 0,
    star_count INT DEFAULT 0,
    undefined_count INT DEFAULT 0,
    refined_count INT DEFAULT 0,
    notes TEXT
);

-- Создание таблицы Object
CREATE TABLE IF NOT EXISTS `Object` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(50) NOT NULL,
    `precision` FLOAT NOT NULL,
    quantity INT DEFAULT 1,
    time TIME NOT NULL,
    date DATE NOT NULL,
    notes TEXT
);

-- Создание таблицы NaturalObject
CREATE TABLE IF NOT EXISTS NaturalObject (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(50) NOT NULL,
    galaxy VARCHAR(100),
    accuracy FLOAT NOT NULL,
    flux FLOAT NOT NULL,
    associated_objects VARCHAR(255),
    notes TEXT
);

-- Создание таблицы Position
CREATE TABLE IF NOT EXISTS `Position` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    earth_position VARCHAR(255) NOT NULL,
    sun_position VARCHAR(255) NOT NULL,
    moon_position VARCHAR(255) NOT NULL
);

-- Создание таблицы Relations
CREATE TABLE IF NOT EXISTS Relations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sector_id INT,
    object_id INT,
    natural_id INT,
    position_id INT,
    FOREIGN KEY (sector_id) REFERENCES Sector(id),
    FOREIGN KEY (object_id) REFERENCES Object(id),
    FOREIGN KEY (natural_id) REFERENCES NaturalObject(id),
    FOREIGN KEY (position_id) REFERENCES `Position`(id)
);

-- Индексы для ускорения поиска по внешним ключам
CREATE INDEX idx_sector ON Relations(sector_id);
CREATE INDEX idx_object ON Relations(object_id);
CREATE INDEX idx_natural ON Relations(natural_id);
CREATE INDEX idx_position ON Relations(position_id);


ALTER TABLE Object ADD COLUMN date_update DATETIME;

DELIMITER $$

CREATE TRIGGER UpdateDate
AFTER UPDATE ON Object
FOR EACH ROW
BEGIN
    UPDATE Object SET date_update = NOW() WHERE id = NEW.id;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE JoinTables(IN table1 VARCHAR(64), IN table2 VARCHAR(64))
BEGIN
    SET @sql = CONCAT('SELECT * FROM ', table1, ' JOIN ', table2, ' ON ', table1, '.id = ', table2, '.id');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$

DELIMITER ;

CREATE PROCEDURE `UpdateSector`(
    IN p_coordinates VARCHAR(255),
    IN p_light_intensity FLOAT,
    IN p_foreign_objects INT,
    IN p_star_count INT,
    IN p_undefined_count INT,
    IN p_refined_count INT,
    IN p_notes TEXT
)
BEGIN
    INSERT INTO Sector (
        coordinates, 
        light_intensity, 
        foreign_objects, 
        star_count, 
        undefined_count, 
        refined_count, 
        notes
    ) VALUES (
        p_coordinates, 
        p_light_intensity, 
        p_foreign_objects, 
        p_star_count, 
        p_undefined_count, 
        p_refined_count, 
        p_notes
    );
END$$

DELIMITER ;
INSERT INTO Sector (coordinates, light_intensity, foreign_objects, star_count, undefined_count, refined_count, notes)
VALUES
('10.7522° N, 63.3836° W', 5.5, 2, 50, 3, 47, 'Very clear night'),
('11.9454° N, 62.7861° W', 3.2, 5, 40, 5, 35, 'Cloudy night'),
('12.1132° N, 60.5468° W', 6.0, 0, 60, 2, 58, 'Perfect observation conditions'),
('12.9734° N, 59.8765° W', 4.8, 3, 30, 6, 24, 'Some light pollution'),
('13.7045° N, 58.2341° W', 7.1, 1, 70, 1, 69, 'Excellent visibility');

INSERT INTO Object (type, `precision`, quantity, time, date, notes)
VALUES
('Star', 0.98, 1, '21:00:00', '2023-06-24', 'Visible near Orion'),
('Galaxy', 0.90, 1, '22:15:00', '2023-06-24', 'Andromeda visible'),
('Meteor', 0.75, 1, '23:00:00', '2023-06-24', 'Spotted a fast meteor'),
('Planet', 0.95, 1, '00:30:00', '2023-06-25', 'Jupiter bright and clear'),
('Comet', 0.80, 1, '01:45:00', '2023-06-25', 'Comet NEOWISE in the sky');

INSERT INTO NaturalObject (type, galaxy, accuracy, flux, associated_objects, notes)
VALUES
('Star', NULL, 0.99, 1.5, 'None', 'A distant sun'),
('Galaxy', 'Milky Way', 0.89, 2.2, 'Surrounding stars', 'Visible arm of our galaxy'),
('Black Hole', 'Andromeda', 0.92, 0.5, 'Affected stars', 'Massive and intriguing'),
('Nebula', NULL, 0.85, 3.0, 'Nearby gas clouds', 'Colorful and expansive'),
('Exoplanet', NULL, 0.93, 0.3, 'Host star visible', 'Possible Earth-like planet');

INSERT INTO Position (earth_position, sun_position, moon_position)
VALUES
('Lat: 34.0522° N, Long: 118.2437° W', '330°', '45°'),
('Lat: 40.7128° N, Long: 74.0060° W', '340°', '50°'),
('Lat: 37.7749° N, Long: 122.4194° W', '350°', '55°'),
('Lat: 47.6062° N, Long: 122.3321° W', '10°', '60°'),
('Lat: 34.0522° N, Long: 118.2437° W', '20°', '65°');

INSERT INTO Relations (sector_id, object_id, natural_id, position_id)
VALUES
(1, 1, 1, 1),
(2, 2, 2, 2),
(3, 3, 3, 3),
(4, 4, 4, 4),
(5, 5, 5, 5);