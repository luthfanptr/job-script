-- Unpivot |cuma ambil tanggal terbesar, ga termasuk value keseluruhan jg|
WITH unpivot_tbl AS (
    SELECT
        [0] AS PLC_ID, [1], [2], [3], [4], [5], [6],
        TRY_CAST(mem AS INT) AS mem, value,
        -- konversi string-datetime
        CONVERT(DATETIME2(0), 
        CONCAT(
        '20', RIGHT('0' + CAST([1] AS VARCHAR), 2), '-',
              RIGHT('0' + CAST([2] AS VARCHAR), 2), '-',
              RIGHT('0' + CAST([3] AS VARCHAR), 2), ' ',
              RIGHT('0' + CAST([4] AS VARCHAR), 2), ':',
              RIGHT('0' + CAST([5] AS VARCHAR), 2), ':',
              RIGHT('0' + CAST([6] AS VARCHAR), 2)
            )
        ) AS datetime_record
    FROM (
        SELECT
            [0],[1], [2], [3], [4], [5], [6],
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
    ) AS src
    UNPIVOT (
        value FOR mem IN (
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
    WHERE [0] = 190 -- AND [1] = 26 AND [2] = 4 AND [3] = 3
    --ORDER BY PLC_ID, mem, [1], [2], [3], [4], [5], [6] --TRY_CAST( AS INT)
)
SELECT PLC_ID, mem, value, MAX(datetime_record) AS latest
FROM unpivot_tbl
GROUP BY PLC_ID, mem, value
ORDER BY mem, latest





-- query convert string ke datetime 
SELECT PLC_ID, [1], [2], [3], [4], [5], [6], mem, value
CONVERT(DATETIME, CONCAT
    '20', RIGHT('0' + CAST([1] AS VARCHAR), 2), '-',
          RIGHT('0' + CAST([2] AS VARCHAR), 2), '-',
          RIGHT('0' + CAST([3] AS VARCHAR), 2), ' ',
          RIGHT('0' + CAST([4] AS VARCHAR), 2), ':',
          RIGHT('0' + CAST([5] AS VARCHAR), 2), ':',
          RIGHT('0' + CAST([6] AS VARCHAR), 2)
    )
) AS datetime_record
FROM





-- query ver updated yg ambil latest aja
SELECT
    PLC_ID,
    mem,
    value,
    datetime_record AS latest
FROM (
    SELECT
        [0] AS PLC_ID,
        TRY_CAST(mem AS INT) AS mem,
        value,

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
            PARTITION BY TRY_CAST(mem AS INT)
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
    ) AS src

    UNPIVOT (
        value FOR mem IN (
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

    WHERE [0] = 190
) AS final_data

WHERE rn = 1
ORDER BY mem;