-- ============================================================
-- PROYECTO: ALKE WALLET V2
-- MÓDULO: FUNDAMENTOS DE BASES DE DATOS RELACIONALES
-- ============================================================
-- Motor utilizado: MySQL 8
-- ============================================================


-- ============================================================
-- 1. CREAR BASE DE DATOS
-- ============================================================

DROP DATABASE IF EXISTS AlkeWallet;

CREATE DATABASE AlkeWallet;

USE AlkeWallet;


-- ============================================================
-- 2. VERIFICAR CREACIÓN DE LA BASE DE DATOS
-- ============================================================

SHOW DATABASES;


-- ============================================================
-- 3. CREAR TABLA MONEDA
-- ============================================================

CREATE TABLE moneda (
    currency_id INT AUTO_INCREMENT PRIMARY KEY,
    currency_name VARCHAR(50) NOT NULL,
    currency_symbol VARCHAR(10) NOT NULL
);


-- ============================================================
-- 4. CREAR TABLA USUARIO
-- ============================================================

CREATE TABLE usuario (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(150) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,
    saldo DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    currency_id INT NOT NULL,

    CONSTRAINT fk_usuario_moneda
        FOREIGN KEY (currency_id)
        REFERENCES moneda(currency_id)
);


-- ============================================================
-- 5. CREAR TABLA TRANSACCION
-- ============================================================

CREATE TABLE transaccion (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_user_id INT NOT NULL,
    receiver_user_id INT NOT NULL,
    currency_id INT NOT NULL,
    importe DECIMAL(12,2) NOT NULL,
    transaction_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_transaccion_emisor
        FOREIGN KEY (sender_user_id)
        REFERENCES usuario(user_id),

    CONSTRAINT fk_transaccion_receptor
        FOREIGN KEY (receiver_user_id)
        REFERENCES usuario(user_id),

    CONSTRAINT fk_transaccion_moneda
        FOREIGN KEY (currency_id)
        REFERENCES moneda(currency_id)
);


-- ============================================================
-- 6. VERIFICAR TABLAS CREADAS
-- ============================================================

SHOW TABLES;

DESCRIBE moneda;

DESCRIBE usuario;

DESCRIBE transaccion;


-- ============================================================
-- 7. INSERTAR MONEDAS
-- ============================================================

INSERT INTO moneda
(currency_name, currency_symbol)
VALUES
('Peso Chileno', '$'),
('Dolar Estadounidense', 'US$'),
('Euro', 'EUR');


-- ============================================================
-- 8. CONSULTAR MONEDAS
-- ============================================================

SELECT *
FROM moneda;


-- ============================================================
-- 9. INSERTAR USUARIOS
-- ============================================================

INSERT INTO usuario
(nombre, correo, contrasena, saldo, currency_id)
VALUES
('Angelica Peña', 'angelica@email.com', 'clave123', 850000.00, 1),
('Juan Perez', 'juan@email.com', 'clave456', 1200.00, 2),
('Camila Soto', 'camila@email.com', 'clave789', 950.00, 3);


-- ============================================================
-- 10. CONSULTAR USUARIOS
-- ============================================================

SELECT *
FROM usuario;


-- ============================================================
-- 11. CONSULTA INNER JOIN USUARIO - MONEDA
-- ============================================================

SELECT
    u.user_id,
    u.nombre,
    u.saldo,
    m.currency_name,
    m.currency_symbol
FROM usuario AS u
INNER JOIN moneda AS m
    ON u.currency_id = m.currency_id;


-- ============================================================
-- 12. OBTENER MONEDA DE UN USUARIO ESPECÍFICO
-- ============================================================

SELECT
    u.nombre,
    m.currency_name
FROM usuario AS u
INNER JOIN moneda AS m
    ON u.currency_id = m.currency_id
WHERE u.user_id = 1;


-- ============================================================
-- 13. INSERTAR TRANSACCIONES DE PRUEBA
-- ============================================================

INSERT INTO transaccion
(sender_user_id, receiver_user_id, currency_id, importe)
VALUES
(1, 2, 1, 50000.00),
(2, 3, 2, 100.00),
(3, 1, 3, 50.00);


-- ============================================================
-- 14. CONSULTAR TODAS LAS TRANSACCIONES
-- ============================================================

SELECT *
FROM transaccion;


-- ============================================================
-- 15. MOSTRAR TRANSACCIONES CON INFORMACIÓN COMPLETA
-- ============================================================

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


-- ============================================================
-- 16. TRANSACCIONES DE UN USUARIO ESPECÍFICO
-- ============================================================

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


-- ============================================================
-- 17. MODIFICAR CORREO DE UN USUARIO
-- ============================================================

UPDATE usuario
SET correo = 'angelica.pena@email.com'
WHERE user_id = 1;


-- Verificar modificación

SELECT
    user_id,
    nombre,
    correo
FROM usuario
WHERE user_id = 1;


-- ============================================================
-- 18. ELIMINAR UNA TRANSACCIÓN
-- ============================================================

-- Consultar antes de eliminar

SELECT *
FROM transaccion
WHERE transaction_id = 2;


-- Eliminar fila completa

DELETE FROM transaccion
WHERE transaction_id = 2;


-- Verificar eliminación

SELECT *
FROM transaccion;


-- ============================================================
-- 19. AGREGAR FECHA DE CREACIÓN A USUARIO
-- TAREA PLUS - ALTER TABLE
-- ============================================================

ALTER TABLE usuario
ADD COLUMN fecha_creacion DATETIME
NOT NULL DEFAULT CURRENT_TIMESTAMP;


-- Verificar modificación

DESCRIBE usuario;


-- ============================================================
-- 20. INSERTAR NUEVO USUARIO EN PESOS CHILENOS
-- ============================================================

INSERT INTO usuario
(nombre, correo, contrasena, saldo, currency_id)
VALUES
('Pedro Gonzales', 'pedro@email.com', 'clave101', 100000.00, 1);


-- ============================================================
-- 21. TRANSACCIÓN CONTROLADA CON COMMIT
-- ============================================================

START TRANSACTION;


-- Descontar $20.000 al usuario emisor

UPDATE usuario
SET saldo = saldo - 20000.00
WHERE user_id = 1;


-- Aumentar $20.000 al usuario receptor

UPDATE usuario
SET saldo = saldo + 20000.00
WHERE user_id = 4;


-- Registrar transferencia

INSERT INTO transaccion
(sender_user_id, receiver_user_id, currency_id, importe)
VALUES
(1, 4, 1, 20000.00);


-- Comprobar saldos

SELECT
    user_id,
    nombre,
    saldo
FROM usuario
WHERE user_id IN (1, 4);


-- Confirmar cambios

COMMIT;


-- ============================================================
-- 22. SIMULAR ERROR DE INTEGRIDAD Y ROLLBACK
-- ============================================================

START TRANSACTION;


-- Modificación temporal del saldo

UPDATE usuario
SET saldo = saldo - 100000.00
WHERE user_id = 1;


-- Ver saldo temporal

SELECT
    user_id,
    nombre,
    saldo
FROM usuario
WHERE user_id = 1;


-- ============================================================
-- IMPORTANTE:
-- La siguiente sentencia genera un error intencional porque
-- no existe un usuario con user_id = 99.
--
-- Debe ejecutarse MANUALMENTE durante la demostración.
-- ============================================================

-- INSERT INTO transaccion
-- (sender_user_id, receiver_user_id, currency_id, importe)
-- VALUES
-- (1, 99, 1, 10000.00);


-- Revertir cambios

ROLLBACK;


-- Verificar recuperación del saldo

SELECT
    user_id,
    nombre,
    saldo
FROM usuario
WHERE user_id = 1;


-- ============================================================
-- 23. FUNCIONES DE AGREGACIÓN
-- ============================================================

-- Cantidad total de transacciones

SELECT
    COUNT(*) AS total_transacciones
FROM transaccion;


-- Suma de importes registrada
-- Solo como demostración técnica de SUM

SELECT
    SUM(importe) AS importe_total
FROM transaccion;


-- ============================================================
-- 24. AGRUPAR TRANSACCIONES POR MONEDA
-- ============================================================

SELECT
    m.currency_name AS moneda,
    COUNT(t.transaction_id) AS cantidad_transacciones,
    SUM(t.importe) AS total_movido
FROM transaccion AS t

INNER JOIN moneda AS m
    ON t.currency_id = m.currency_id

GROUP BY
    m.currency_id,
    m.currency_name;


-- ============================================================
-- 25. SUBCONSULTA:
-- TOTAL DE TRANSACCIONES POR USUARIO
-- ============================================================

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


-- ============================================================
-- 26. CREAR ÍNDICES COMPUESTOS
-- ============================================================

CREATE INDEX idx_transaccion_emisor_fecha
ON transaccion
(sender_user_id, transaction_date);


CREATE INDEX idx_transaccion_receptor_fecha
ON transaccion
(receiver_user_id, transaction_date);


-- Verificar índices

SHOW INDEX FROM transaccion;


-- ============================================================
-- 27. CREAR VISTA TOP 5 USUARIOS CON MAYOR SALDO
-- TAREA PLUS
-- ============================================================

CREATE VIEW top_5_usuarios_saldo AS

SELECT
    user_id,
    nombre,
    saldo
FROM usuario
ORDER BY saldo DESC
LIMIT 5;


-- ============================================================
-- 28. CONSULTAR VISTA
-- ============================================================

SELECT *
FROM top_5_usuarios_saldo;


-- ============================================================
-- 29. VERIFICAR TABLAS Y VISTAS
-- ============================================================

SHOW FULL TABLES;


-- ============================================================
-- FIN DEL SCRIPT
-- ALKE WALLET V2
-- ============================================================