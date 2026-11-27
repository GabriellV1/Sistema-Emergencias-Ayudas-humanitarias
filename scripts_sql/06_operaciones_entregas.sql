-- Buscar entregas por solicitud.
CREATE INDEX idx_entrega_solicitud
ON entrega (cod_solicitud);


