-- CRIAÇÃO DO BANCO
CREATE DATABASE oficina;
USE oficina;

-- CLIENTES
CREATE TABLE cliente (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100),
    telefone VARCHAR(20),
    email VARCHAR(100)
);

-- VEÍCULOS
CREATE TABLE veiculo (
    placa VARCHAR(10) PRIMARY KEY,
    modelo VARCHAR(50),
    ano INT,
    id_cliente INT,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
);

-- EQUIPES
CREATE TABLE equipe (
    id_equipe INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100)
);

-- MECÂNICOS
CREATE TABLE mecanico (
    id_mecanico INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100),
    especialidade VARCHAR(100),
    id_equipe INT,
    FOREIGN KEY (id_equipe) REFERENCES equipe(id_equipe)
);

-- SERVIÇOS
CREATE TABLE servico (
    id_servico INT PRIMARY KEY AUTO_INCREMENT,
    descricao VARCHAR(255),
    valor_base DECIMAL(10,2)
);

-- ORDEM DE SERVIÇO (OS)
CREATE TABLE ordem_servico (
    id_os INT PRIMARY KEY AUTO_INCREMENT,
    data_abertura DATE,
    data_entrega DATE,
    id_veiculo VARCHAR(10),
    id_equipe INT,
    FOREIGN KEY (id_veiculo) REFERENCES veiculo(placa),
    FOREIGN KEY (id_equipe) REFERENCES equipe(id_equipe)
);

-- ITENS DA OS (SERVIÇOS REALIZADOS)
CREATE TABLE item_os (
    id_item INT PRIMARY KEY AUTO_INCREMENT,
    id_os INT,
    id_servico INT,
    quantidade INT,
    valor_final DECIMAL(10,2),
    FOREIGN KEY (id_os) REFERENCES ordem_servico(id_os),
    FOREIGN KEY (id_servico) REFERENCES servico(id_servico)
);

-- DADOS DE TESTE
INSERT INTO cliente (nome, telefone, email) VALUES
('Carlos Santos', '11988887777', 'carlos@email.com'),
('Ana Beatriz', '21999998888', 'ana@email.com');

INSERT INTO veiculo (placa, modelo, ano, id_cliente) VALUES
('ABC1234', 'Gol G5', 2012, 1),
('XYZ9876', 'Civic', 2019, 2);

INSERT INTO equipe (nome) VALUES
('Equipe A'), ('Equipe B');

INSERT INTO mecanico (nome, especialidade, id_equipe) VALUES
('João Silva', 'Motor', 1),
('Maria Lima', 'Freios', 1),
('Pedro Rocha', 'Elétrica', 2);

INSERT INTO servico (descricao, valor_base) VALUES
('Troca de óleo', 100.00),
('Alinhamento', 120.00),
('Revisão elétrica', 200.00);

INSERT INTO ordem_servico (data_abertura, data_entrega, id_veiculo, id_equipe) VALUES
('2025-07-01', '2025-07-03', 'ABC1234', 1),
('2025-07-05', '2025-07-07', 'XYZ9876', 2);

INSERT INTO item_os (id_os, id_servico, quantidade, valor_final) VALUES
(1, 1, 1, 100.00),
(1, 2, 1, 120.00),
(2, 3, 1, 200.00);

-- CONSULTAS SQL COMPLEXAS

-- 1. Lista de ordens com nome do cliente, veículo e total da OS
SELECT 
    os.id_os,
    c.nome AS cliente,
    v.modelo,
    SUM(i.valor_final) AS total_os
FROM 
    ordem_servico os
JOIN veiculo v ON os.id_veiculo = v.placa
JOIN cliente c ON v.id_cliente = c.id_cliente
JOIN item_os i ON os.id_os = i.id_os
GROUP BY os.id_os, c.nome, v.modelo;

-- 2. Filtro: Ordens de serviço com valor total superior a 150
SELECT 
    os.id_os,
    c.nome AS cliente,
    SUM(i.valor_final) AS total_os
FROM 
    ordem_servico os
JOIN veiculo v ON os.id_veiculo = v.placa
JOIN cliente c ON v.id_cliente = c.id_cliente
JOIN item_os i ON os.id_os = i.id_os
GROUP BY os.id_os, c.nome
HAVING total_os > 150;

-- 3. Lista de serviços por mecânico da Equipe A
SELECT 
    m.nome AS mecanico,
    e.nome AS equipe,
    s.descricao AS servico
FROM 
    mecanico m
JOIN equipe e ON m.id_equipe = e.id_equipe
JOIN ordem_servico os ON os.id_equipe = e.id_equipe
JOIN item_os io ON io.id_os = os.id_os
JOIN servico s ON io.id_servico = s.id_servico
WHERE e.nome = 'Equipe A'
ORDER BY m.nome;

-- 4. Quantidade de OS por equipe
SELECT 
    e.nome AS equipe,
    COUNT(os.id_os) AS total_os
FROM 
    equipe e
LEFT JOIN ordem_servico os ON os.id_equipe = e.id_equipe
GROUP BY e.nome;

-- 5. Clientes que mais gastaram (ordenação por total gasto)
SELECT 
    c.nome,
    SUM(i.valor_final) AS total_gasto
FROM 
    cliente c
JOIN veiculo v ON c.id_cliente = v.id_cliente
JOIN ordem_servico os ON v.placa = os.id_veiculo
JOIN item_os i ON os.id_os = i.id_os
GROUP BY c.nome
ORDER BY total_gasto DESC;
