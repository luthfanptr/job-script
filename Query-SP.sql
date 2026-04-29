-- Stored Procedure

CREATE OR ALTER PROCEDURE [dbo].[SP_JOB]
    @DATE_FILTER DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Default ke hari ini jika parameter tidak diisi
    IF @DATE_FILTER IS NULL
        SET @DATE_FILTER = CAST(GETDATE() AS DATE);

    WITH unpvt_val_date AS (
        SELECT
            PLC_ID,
            mem,
            DATA_VALUE,
            datetime_record AS PLC_DATE
        FROM (
            SELECT
                [0] AS PLC_ID,
                TRY_CAST(mem AS INT) AS mem,
                DATA_VALUE,

                CONVERT(DATETIME2(0),
                    CONCAT(
                        '20', RIGHT('0' + CAST([1] AS VARCHAR), 2), '-',
                        RIGHT('0' + CAST([2] AS VARCHAR), 2), '-',
                        RIGHT('0' + CAST([3] AS VARCHAR), 2), ' ',
                        RIGHT('0' + CAST([4] AS VARCHAR), 2), ':',
                        RIGHT('0' + CAST([5] AS VARCHAR), 2), ':',
                        RIGHT('0' + CAST([6] AS VARCHAR), 2)
                    )
                ) AS datetime_record,

                ROW_NUMBER() OVER (
                    PARTITION BY [0], TRY_CAST(mem AS INT)
                    ORDER BY
                        CONVERT(DATETIME2(0),
                            CONCAT(
                                '20', RIGHT('0' + CAST([1] AS VARCHAR), 2), '-',
                                RIGHT('0' + CAST([2] AS VARCHAR), 2), '-',
                                RIGHT('0' + CAST([3] AS VARCHAR), 2), ' ',
                                RIGHT('0' + CAST([4] AS VARCHAR), 2), ':',
                                RIGHT('0' + CAST([5] AS VARCHAR), 2), ':',
                                RIGHT('0' + CAST([6] AS VARCHAR), 2)
                            )
                        ) DESC
                ) AS rn

            FROM (
                SELECT
                    [0],[1],[2],[3],[4],[5],[6],
                    [130],[131],[132],[133],[134],
                    [135],[136],[137],[138],[139],
                    [140],[141],[142],[143],[144],
                    [145],[146],[147],[148],[149],
                    [150],[151],[152],[153],[154],
                    [155],[156],[157],[158],[159],
                    [160],[161],[162],[163],[164],
                    [165],[166],[167],[168],[169],
                    [170],[171],[172],[173],[174],
                    [175],[176],[177],[178],[179]
                FROM MINA_IOT_PKL.dbo.MC_DATA
                WHERE FORMAT(@DATE_FILTER,'yy') = [1]
                  AND MONTH(@DATE_FILTER) = [2]
                  AND DAY(@DATE_FILTER)   = [3]
            ) AS src

            UNPIVOT (
                DATA_VALUE FOR mem IN (
                    [130],[131],[132],[133],[134],
                    [135],[136],[137],[138],[139],
                    [140],[141],[142],[143],[144],
                    [145],[146],[147],[148],[149],
                    [150],[151],[152],[153],[154],
                    [155],[156],[157],[158],[159],
                    [160],[161],[162],[163],[164],
                    [165],[166],[167],[168],[169],
                    [170],[171],[172],[173],[174],
                    [175],[176],[177],[178],[179]
                )
            ) AS unpvt

        ) AS final_data
        WHERE rn = 1
    ),
    master_ref AS (
        SELECT
            dtl.[PLC_ID],
            dtl.[MC_ID],
            msl.[PLANT],
            msc.[LINE],
            msl.[LINE_NM],
            dtl.[MC_DATA_NAME],
            CASE WHEN dtl.MC_DATA_NAME LIKE '%LIMIT%' THEN 'LIMIT' ELSE 'COUNTER' END AS COUNTER_LIMIT
        FROM [MINA_IOT_PKL].[dbo].[MC_DATA_REF_dtl] dtl
        JOIN [MINA_IOT_PKL].[dbo].[MS_MC] msc
            ON dtl.[PLC_ID] = msc.[PLC_ID]
        JOIN [MINA_IOT_PKL].[dbo].[MS_LINE] msl
            ON msc.[LINE_ID] = msl.[LINE_ID]
        WHERE dtl.[CAT_ID] = 4
          AND dtl.MC_DATA_NAME <> ''
    )

    SELECT
        mref.PLC_ID,
        mref.MC_ID,
        mref.PLANT,
        mref.LINE,
        mref.LINE_NM,
        mref.MC_DATA_NAME,
        mref.COUNTER_LIMIT,
        unpvt.DATA_VALUE,
        unpvt.PLC_DATE
    FROM master_ref mref
    JOIN unpvt_val_date unpvt
        ON mref.PLC_ID = unpvt.PLC_ID
        AND mref.MC_ID = unpvt.mem
    ORDER BY
        mref.PLC_ID,
        unpvt.mem;

END;
GO