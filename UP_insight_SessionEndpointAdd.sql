CREATE OR REPLACE PROCEDURE dbo."UP_insight_SessionEndpointAdd"
(
    IN       pi_SessionId               UUID,
    IN       pi_EndpointId              INTEGER,
    IN       pi_Failed                  BOOLEAN,
    IN       pi_DateStarted             TIMESTAMP,
    IN       pi_DateCompleted           TIMESTAMP,
    IN       pi_CallbackToken           VARCHAR(256),
    IN       pi_MacthingMessageCount    INTEGER,
    INOUT    po_ReturnValue             INTEGER,
    INOUT    po_ResultSet               REFCURSOR
)
    LANGUAGE 'plpgsql'
AS
$BODY$
-- ========================================================================================================
-- Description : 
--             :
-- Author      : 
-- --------------------------------------------------------------------------------------------------------
-- [Change History]
-- --------------------------------------------------------------------------------------------------------
-- Date (yyyy-mm-dd)  Changed By             Build               Etrack/Jira     Change "Description"
--
-- 2020-06-18         Jayaprakash[k1]        20_02_RobsonDB                      Migrated from SQL Server
--
-- ------------------------------------------------------------------------------------------------------------
-- [COPYIGHT NOTICE]
-- ------------------------------------------------------------------------------------------------------------
-- Copyright © 2020 Broadcom. All rights reserved.
-- The term “Broadcom” refers to Broadcom Inc. and/or its subsidiaries.
-- 
-- This software and all information contained therein is confidential and proprietary and shall not be
-- duplicated, used, disclosed or disseminated in any way except as authorized by the applicable license agreement,
-- without the express written permission of Broadcom. All authorized reproductions must be marked with this language.
-- 
-- EXCEPT AS SET FORTH IN THE APPLICABLE LICENSE AGREEMENT, TO THE EXTENT PERMITTED BY APPLICABLE LAW OR
-- AS AGREED BY BROADCOM IN ITS APPLICABLE LICENSE AGREEMENT, BROADCOM PROVIDES THIS DOCUMENTATION “AS IS”
-- WITHOUT WARRANTY OF ANY KIND, INCLUDING WITHOUT LIMITATION, ANY IMPLIED WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE, OR NONINFRINGEMENT. IN NO EVENT WILL BROADCOM BE LIABLE TO THE END USER OR
-- ANY THIRD PARTY FOR ANY LOSS OR DAMAGE, DIRECT OR INDIRECT, FROM THE USE OF THIS DOCUMENTATION,
-- INCLUDING WITHOUT LIMITATION, LOST PROFITS, LOST INVESTMENT, BUSINESS INTERRUPTION, GOODWILL, OR LOST DATA,
-- EVEN IF BROADCOM IS EXPRESSLY ADVISED IN ADVANCE OF THE POSSIBILITY OF SUCH LOSS OR DAMAGE
-- ======================================================================================================== 
DECLARE
    v_Error                INTEGER;
    v_ErrorMessage         VARCHAR(255);
    v_SessionEndpointId    INTEGER;
	
    BEGIN
    IF pi_DateCompleted <= pi_DateStarted
    THEN
        SELECT v_ErrorMessage = '**>>ERROR(' || OBJECT_NAME(@@PROCID) || '): error code [' || STR(v_Error) || '] The completed date must be after the started date'; 
        RAISE EXCEPTION '%',v_ErrorMessage;
          po_ReturnValue = ERROR;
    END IF;
  
    IF NOT EXISTS (SELECT 1 FROM dbo."Session" WHERE SessionId = pi_SessionId)
    THEN
        SELECT v_ErrorMessage = '**>> ERROR (' || OBJECT_NAME(@@PROCID) ||'): error code [' || STR(v_Error) ||'] invalid SessionId';
        RAISE EXCEPTION '%',v_ErrorMessage;
          po_ReturnValue = ERROR;
    END IF;
 
    IF NOT EXISTS (SELECT 1 FROM dbo."EndpointId" WHERE EndpointId = pi_EndpointId)
    THEN
        SELECT v_ErrorMessage = '**>> ERROR (' || OBJECT_NAME(@@PROCID) ||'): error code [' || STR(v_Error) ||'] invalid EndpointId';
        RAISE EXCEPTION '%',v_ErrorMessage;
          po_ReturnValue = ERROR;
    END IF;
																  
    INSERT INTO  dbo."SessionEndpoint"
    (
        "SessionId",
        "EndpointId",
        "Failed",
        "DateStarted",
        "DateCompleted",
        "CallbackToken",
        "MatchingMessagesCount",
        "DateCreated",
        "DateAmended",
        "WhoAmended_nt_username"
    )
    VALUES
    (
        pi_SessionId,
        pi_EndpointId, 
        pi_Failed,
        pi_DateStarted,
        pi_DateCompleted,
        pi_CallbackToken,
        pi_MatchingMessagesCount,
        GETDATE(),
        GETDATE(),
        USER_NAME()
    );
SELECT
        v_Error = ERROR,
        pi_SessionEndpointId = SCOPE_IDENTITY();

    IF Error <> 0
    THEN
        SELECT @vcErrorMessage = '**>> ERROR(' || OBJECT_NAME(@@PROCID)||'): insert SessionEndpoint' ;
        RAISE EXCEPTION '%',v_ErrorMessage;
        po_ReturnValue = ERROR;
    END IF;

    SELECT
        SessionEndpointId,
        SessionId,
        EndpointId,
        Failed,
        DateStarted,
        DateCompleted,
        CallbackToken,
        MatchingMessagesCount,
        DateCreated,
        DateAmended,
        WhoAmended_nt_username,
        WhoAmended_hostname
    FROM dbo."SessionEndpoint"
    WHERE
       SessionEndpointId = pi_SessionEndpointId;
            po_ReturnValue = 0;
END;
$BODY$;