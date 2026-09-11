-- ============================================================================
-- Object: [dbo].[vw_IndexSecurityRaw] (VIEW)
-- Source File: dbo\Views\vw_IndexSecurityRaw.sql
-- ============================================================================
-- Auto Generated (Do not modify) CE5B86CE37DA3CE39DD64CB1800E274628A8A2A48ECF8C72B6E3DDB4FC9E8875

CREATE VIEW vw_IndexSecurityRaw
AS
SELECT FORMAT(GETDATE(),'MM/dd/yyyy') AS AsOfDate,
    BenchmarkCode,
    Identifier,
    CurrentFace
FROM IndexSecurityRaw 
WHERE AsOfDate = '10-16-2024'

GO