-- =====================================================
-- PROYECTO: ALKE WALLET V2
-- MÓDULO: FUNDAMENTOS DE BASES DE DATOS RELACIONALES
-- =====================================================


-- =====================================================
-- 1. CREAR LA BASE DE DATOS
-- =====================================================

CREATE DATABASE IF NOT EXISTS AlkeWallet;


-- =====================================================
-- 2. SELECCIONAR LA BASE DE DATOS
-- =====================================================

USE AlkeWallet;


-- =====================================================
-- 3. VERIFICAR LA CREACIÓN
-- =====================================================

SHOW DATABASES;


-- =====================================================
-- 4. VERIFICAR TABLAS EXISTENTES
-- =====================================================

SHOW TABLES;


-- =====================================================
-- 5. CREAR TABLA MONEDA
-- =====================================================

CREATE TABLE moneda (
    currency_id INT AUTO_INCREMENT PRIMARY KEY,
    currency_name VARCHAR(50) NOT NULL,
    currency_symbol VARCHAR(10) NOT NULL
);


-- =====================================================
-- 6. VERIFICAR TABLAS
-- =====================================================

SHOW TABLES;


-- =====================================================
-- 7. VER ESTRUCTURA DE LA TABLA MONEDA
-- =====================================================

DESCRIBE moneda;


-- =====================================================
-- 8. INSERTAR MONEDAS
-- =====================================================

INSERT INTO moneda (currency_name, currency_symbol)
VALUES
('Peso Chileno', '$'),
('Dolar Estadounidense', 'US$'),
('Euro', 'EUR');


-- =====================================================
-- 9. CONSULTAR MONEDAS
-- =====================================================

SELECT * FROM moneda;


-- =====================================================
-- 10. CREAR TABLA USUARIO
-- =====================================================

CREATE TABLE usuario (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(150) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,
    saldo DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    currency_id INT NOT NULL,

    FOREIGN KEY (currency_id)
        REFERENCES moneda(currency_id)
);


-- =====================================================
-- 11. VER ESTRUCTURA DE LA TABLA USUARIO
-- =====================================================

DESCRIBE usuario;


-- =====================================================
-- 12. INSERTAR USUARIOS
-- =====================================================

INSERT INTO usuario
(nombre, correo, contrasena, saldo, currency_id)
VALUES
('Angelica Peña', 'angelica@email.com', 'clave123', 850000.00, 1),
('Juan Perez', 'juan@email.com', 'clave456', 1200.00, 2),
('Camila Soto', 'camila@email.com', 'clave789', 950.00, 3);


-- =====================================================
-- 13. CONSULTAR USUARIOS
-- =====================================================

SELECT * FROM usuario;

-- =====================================================
-- 14. CONSULTA INNER JOIN USUARIO - MONEDA
-- =====================================================

SELECT
    u.user_id,
    u.nombre,
    u.saldo,
    m.currency_name,
    m.currency_symbol
FROM usuario AS u
INNER JOIN moneda AS m
    ON u.currency_id = m.currency_id;


-- =====================================================
-- 15. CONSULTAR MONEDA DE UN USUARIO ESPECÍFICO
-- =====================================================

SELECT
    u.nombre,
    m.currency_name
FROM usuario AS u
INNER JOIN moneda AS m
    ON u.currency_id = m.currency_id
WHERE u.user_id = 1;

-- =====================================================
-- 16. CREAR TABLA TRANSACCION
-- =====================================================

CREATE TABLE transaccion (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_user_id INT NOT NULL,
    receiver_user_id INT NOT NULL,
    currency_id INT NOT NULL,
    importe DECIMAL(12,2) NOT NULL,
    transaction_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (sender_user_id)
        REFERENCES usuario(user_id),

    FOREIGN KEY (receiver_user_id)
        REFERENCES usuario(user_id),

    FOREIGN KEY (currency_id)
        REFERENCES moneda(currency_id)
);


-- =====================================================
-- 17. VER ESTRUCTURA TABLA TRANSACCION
-- =====================================================

DESCRIBE transaccion;

-- =====================================================
-- 18. INSERTAR TRANSACCIONES
-- =====================================================

INSERT INTO transaccion
(sender_user_id, receiver_user_id, currency_id, importe)
VALUES
(1, 2, 1, 50000.00),
(2, 3, 2, 100.00),
(3, 1, 3, 50.00);


-- =====================================================
-- 19. CONSULTAR TODAS LAS TRANSACCIONES
-- =====================================================

SELECT * FROM transaccion;

-- =====================================================
-- 20. MOSTRAR TRANSACCIONES CON DATOS COMPLETOS
-- =====================================================

SELECT
    t.transaction_id,
    emisor.nombre AS emisor,
    receptor.nombre AS receptor,
    t.importe,
    m.currency_name AS moneda,
    m.currency_symbol AS simbolo,
    t.transaction_date
FROM transaccion AS t
INNER JOIN usuario AS emisor
    ON t.sender_user_id = emisor.user_id
INNER JOIN usuario AS receptor
    ON t.receiver_user_id = receptor.user_id
INNER JOIN moneda AS m
    ON t.currency_id = m.currency_id;

-- =====================================================
-- 21. CONSULTAR TRANSACCIONES DE UN USUARIO ESPECÍFICO
-- =====================================================

SELECT
    t.transaction_id,
    emisor.nombre AS emisor,
    receptor.nombre AS receptor,
    t.importe,
    m.currency_name AS moneda,
    t.transaction_date
FROM transaccion AS t
INNER JOIN usuario AS emisor
    ON t.sender_user_id = emisor.user_id
INNER JOIN usuario AS receptor
    ON t.receiver_user_id = receptor.user_id
INNER JOIN moneda AS m
    ON t.currency_id = m.currency_id
WHERE t.sender_user_id = 1
   OR t.receiver_user_id = 1;

-- =====================================================
-- 22. MODIFICAR CORREO DE UN USUARIO
-- =====================================================

UPDATE usuario
SET correo = 'angelica.pena@email.com'
WHERE user_id = 1;


-- =====================================================
-- 23. VERIFICAR MODIFICACIÓN
-- =====================================================

SELECT user_id, nombre, correo
FROM usuario
WHERE user_id = 1;

-- =====================================================
-- 24. CONSULTAR TRANSACCIÓN ANTES DE ELIMINAR
-- =====================================================

SELECT *
FROM transaccion
WHERE transaction_id = 2;


-- =====================================================
-- 25. ELIMINAR UNA TRANSACCIÓN
-- =====================================================

DELETE FROM transaccion
WHERE transaction_id = 2;


-- =====================================================
-- 26. VERIFICAR ELIMINACIÓN
-- =====================================================

SELECT * FROM transaccion;

-- =====================================================
-- 27. INSERTAR SEGUNDO USUARIO EN PESOS CHILENOS
-- =====================================================

INSERT INTO usuario
(nombre, correo, contrasena, saldo, currency_id)
VALUES
('Pedro Gonzalez', 'pedro@email.com', 'clave101', 100000.00, 1);


-- =====================================================
-- 28. TRANSFERENCIA CONTROLADA CON TRANSACCIÓN
-- =====================================================

START TRANSACTION;


-- Descontar saldo al emisor
UPDATE usuario
SET saldo = saldo - 20000.00
WHERE user_id = 1;


-- Aumentar saldo al receptor
UPDATE usuario
SET saldo = saldo + 20000.00
WHERE user_id = 4;


-- Registrar movimiento
INSERT INTO transaccion
(sender_user_id, receiver_user_id, currency_id, importe)
VALUES
(1, 4, 1, 20000.00);


-- Verificar saldos antes de confirmar
SELECT user_id, nombre, saldo
FROM usuario
WHERE user_id IN (1, 4);


-- Confirmar cambios
COMMIT;

-- =====================================================
-- 29. SIMULACIÓN DE ERROR Y ROLLBACK
-- =====================================================

START TRANSACTION;


-- Descontar saldo temporalmente
UPDATE usuario
SET saldo = saldo - 10000.00
WHERE user_id = 1;


-- Verificar saldo temporal
SELECT user_id, nombre, saldo
FROM usuario
WHERE user_id = 1;


-- Provocar error de integridad referencial
-- El usuario 99 no existe
INSERT INTO transaccion
(sender_user_id, receiver_user_id, currency_id, importe)
VALUES
(1, 99, 1, 10000.00);


-- Revertir todos los cambios
ROLLBACK;


-- Comprobar que el saldo volvió a su valor original
SELECT user_id, nombre, saldo
FROM usuario
WHERE user_id = 1;

-- =====================================================
-- 30. CONTAR TRANSACCIONES
-- =====================================================

SELECT COUNT(*) AS total_transacciones
FROM transaccion;


-- =====================================================
-- 31. SUMAR IMPORTES REGISTRADOS
-- =====================================================

SELECT SUM(importe) AS importe_total
FROM transaccion;


-- =====================================================
-- 32. AGRUPAR TRANSACCIONES POR MONEDA
-- =====================================================

SELECT
    m.currency_name AS moneda,
    COUNT(t.transaction_id) AS cantidad_transacciones,
    SUM(t.importe) AS total_movido
FROM transaccion AS t
INNER JOIN moneda AS m
    ON t.currency_id = m.currency_id
GROUP BY m.currency_id, m.currency_name;

-- =====================================================
-- 33. SUBCONSULTA: TOTAL DE TRANSACCIONES POR USUARIO
-- =====================================================

SELECT
    u.user_id,
    u.nombre,
    (
        SELECT COUNT(*)
        FROM transaccion AS t
        WHERE t.sender_user_id = u.user_id
           OR t.receiver_user_id = u.user_id
    ) AS total_transacciones
FROM usuario AS u;

-- =====================================================
-- 34. CREAR ÍNDICES COMPUESTOS
-- =====================================================

CREATE INDEX idx_transaccion_emisor_fecha
ON transaccion (sender_user_id, transaction_date);

CREATE INDEX idx_transaccion_receptor_fecha
ON transaccion (receiver_user_id, transaction_date);


-- =====================================================
-- 35. VERIFICAR ÍNDICES
-- =====================================================

SHOW INDEX FROM transaccion;

-- =====================================================
-- 36. AGREGAR FECHA DE CREACIÓN AL USUARIO
-- TAREA PLUS - ALTER TABLE
-- =====================================================

ALTER TABLE usuario
ADD COLUMN fecha_creacion DATETIME
NOT NULL DEFAULT CURRENT_TIMESTAMP;


-- =====================================================
-- 37. VERIFICAR MODIFICACIÓN DE TABLA USUARIO
-- =====================================================

DESCRIBE usuario;


-- =====================================================
-- 38. CONSULTAR FECHA DE CREACIÓN DE USUARIOS
-- =====================================================

SELECT
    user_id,
    nombre,
    fecha_creacion
FROM usuario;

-- =====================================================
-- 39. CREAR VISTA TOP 5 USUARIOS CON MAYOR SALDO
-- TAREA PLUS
-- =====================================================

CREATE VIEW top_5_usuarios_saldo AS
SELECT
    user_id,
    nombre,
    saldo
FROM usuario
ORDER BY saldo DESC
LIMIT 5;


-- =====================================================
-- 40. CONSULTAR VISTA
-- =====================================================

SELECT * FROM top_5_usuarios_saldo;