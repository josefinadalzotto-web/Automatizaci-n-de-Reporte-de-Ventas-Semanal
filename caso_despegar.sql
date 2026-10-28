USE clase;
GO
SELECT 
    channel,
    product_category,
    SUM(amount) AS total_facturado,
    AVG(amount) AS ticket_promedio
FROM ventas_historial
GROUP BY 
    channel, 
    product_category;

DECLARE @fecha_inicio DATE = '2023-10-01';
DECLARE @fecha_fin DATE = '2023-10-07';

SELECT 
    channel,
    product_category,
    SUM(amount) AS total_facturado,
    AVG(amount) AS ticket_promedio
FROM ventas_historial
WHERE date BETWEEN @fecha_inicio AND @fecha_fin
GROUP BY 
    channel,
    product_category;
