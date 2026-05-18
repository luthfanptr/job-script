CREATE OR ALTER PROCEDURE [dbo].[FILTER_PLC_STATUS]
AS
BEGIN
	SET NOCOUNT ON;
	--update data yg sdh ada, hanya ctr, limit, status, date
	UPDATE ps
	SET
		ps.counter = pd.counter,
		ps.limit = pd.[limit],
		ps.status = pd.status,
		ps.plc_date = pd.plc_date,
		ps.updated_at = GETDATE()
	FROM plc_statuses ps
	INNER JOIN plc_data pd
		ON ps.plc_id = pd.plc_id
		AND ps.component_name = pd.component_name
	WHERE pd.status IN ('WARNINIG', 'DANGER');

	--insert data baru yg blm ada di plc_status
	INSERT INTO plc_statuses (plc_id, plant, line, line_name, component_name, counter, [limit], status, plc_date, spk_status, updated_by, created_at, updated_at)
	SELECT
		pd.plc_id, pd.plant, pd.line, pd.line_name, 
		pd.component_name, pd.counter, pd.[limit], pd.status, 
		pd.plc_date, NULL, NULL, GETDATE(), GETDATE()
	FROM plc_data pd
	WHERE pd.status IN ('WARNING', 'DANGER')
	AND NOT EXISTS (
		SELECT 1 FROM plc_statuses ps
        WHERE ps.plc_id = pd.plc_id
        AND ps.component_name = pd.component_name
	);
END;
GO