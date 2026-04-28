-- query nilai counter dan limit
SELECT 
    --PLC_ID,
    --MC_ID,
    --CAT_ID=4,
    MC_DATA_NAME,
    NUM_DIG
FROM MINA_IOT_PKL.dbo.MC_DATA_REF_dtl
WHERE MC_ID BETWEEN 130 AND 179 AND MC_DATA_NAME <> '' AND CAT_ID = 4;

-- query info counter & limit serta line |POV Teknisi|
SELECT TOP (1000)
    dtl.[PLC_ID],
    --msc.[PLC_ID],
    dtl.[MC_ID],
    --dtl.[CAT_ID],
    dtl.[MC_DATA_NAME],
    CASE WHEN dtl.MC_DATA_NAME like '%LIMIT%' THEN 'LIMIT' ELSE 'COUNTER' END COUNTER_LIMIT,
    dtl.[NUM_DIG],
    msc.[LINE],
    msl.[LINE_NM],
    msl.[PLANT]
FROM [MINA_IOT_PKL].[dbo].[MC_DATA_REF_dtl] dtl
JOIN [MINA_IOT_PKL].[dbo].[MS_MC] msc
    ON dtl.[PLC_ID] = msc.[PLC_ID]
JOIN [MINA_IOT_PKL].[dbo].[MS_LINE] msl
    ON msc.[LINE_ID] = msl.[LINE_ID]
    WHERE dtl.[CAT_ID] = 4 AND MC_DATA_NAME <> '';


-- query info plant, line, plc(id & name)
SELECT TOP (1000)
      mc.[PLC_ID],
      mc.[PLC_NM],
      ln.[LINE_NM],
      ln.[PLANT],
      mc.[LINE_ID],
      mc.[LINE],
      mc.[IP],
      mc.[F_LAST],
      mc.[CPU_TYPE],
      mc.[MAKER],
      mc.[USR_UPD],
      mc.[UPD_DT],
      mc.[URUT],
      ln.[LINE_ID]
FROM [MINA_IOT_PKL].[dbo].[MS_MC] mc
JOIN [MINA_IOT_PKL].[dbo].[MS_LINE] ln 
     ON mc.[LINE_ID] = ln.[LINE_ID]
     WHERE mc.[USR_UPD] = 'MINA-Galang-Tasrul';

     --ln.[PLANT] = 'MINA1' AND 
  --WHERE USR_UPD = 'MINA-Galang-Tasrul';
  --where LINE =1;





SELECT TOP 1 *
FROM [MINA_IOT_PKL].[dbo].[MC_DATA]