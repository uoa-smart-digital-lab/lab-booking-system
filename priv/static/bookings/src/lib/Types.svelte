<!------------------------------------------------------------------------------------------------------
  Types for the Finite State Machines used in the application.

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------->
<script context="module" lang="ts">

    import type { Item, Session } from './Graphql.svelte';

    export type QueryVars = {
        name : string,
        qrcode : string,
        qrsearch : string,
        search : string
    };

    export type AppVars = {
        session : Session,
        item : Item,
        message : string
    }

    export enum AppStates { 
        _='*', 
        LOAD='load', 
        INIT='init', 
        VIEW='view', 
        QRSEARCH='qrSearch', 
        QRCODE='qrCode', 
        MAIN_DETAILS='mainDetails', 
        MAIN_BOOKING='mainBooking', 
        MAIN_LIST='mainList',
        ITEM_DETAILS='itemDetails'
    };
    export enum AppEvents {
        LOAD_QUERY_STRINGS='loadQueryStrings', 
        SHOW_QRCODE='showQRCode',
        SHOW_QRSEARCH='showQRSearch',
        SHOW_SEARCH='showSearch',
        SHOW_LIST='showList',
        SHOW_BOOKING='showBooking',
        SHOW_DETAILS='showDetails'
    };

    export enum LoginStates {
        _='*',
        LOAD='load',
        LOGIN_DIALOG_CLOSED="loginDialogClosed",
        LOGIN_DIALOG_OPEN="loginDialogOpen",
        LOGGED_IN='loggedIn',
        LOGGED_OUT='loggedOut'
    }
    export enum LoginEvents {
        INITIALISE="initialise",
        LOG_IN='logIn',
        LOG_OUT='LogOut',
        OPEN_DIALOG='openDialog',
        CLOSE_DIALOG='closeDialog'
    }

</script>
<!----------------------------------------------------------------------------------------------------->