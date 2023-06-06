<!------------------------------------------------------------------------------------------------------
  Main controlling App for Booking System

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import { behavior, Message, Image, Grid, Column, Header, Content } from "svelte-fomantic-ui";

    import { ApolloClient, InMemoryCache } from '@apollo/client';
    import { setClient } from 'svelte-apollo';

    import type { QueryVars, AppVars } from './lib/Types.svelte';
    import { AppStates, AppEvents, LoginStates, LoginEvents } from './lib/Types.svelte';
    import Automation from './lib/FiniteStateMachine';

    import Login from "./lib/Login.svelte";
    import TopBar from "./lib/TopBar.svelte";
    import QRcode from "./lib/QRcode.svelte";
    import Booking from "./lib/Booking.svelte";
    import Items_Loader from "./lib/Items_Loader.svelte";
    
    import { Itemtype, Usertype } from "./lib/Graphql.svelte";
    import type { Item as ItemT, Session } from './lib/Graphql.svelte';
    import { getQueryStringVal } from './lib/Querystring.svelte';

    import { onMount } from 'svelte';

    // -------------------------------------------------------------------------------------------------
    // Window width
    // -------------------------------------------------------------------------------------------------
    let windowWidth: number = 0;
    let numCols: number = 3;

    const setNumCols = () => { 
        if (windowWidth < 512) return 1;
        else if (windowWidth < 768) return 2;
        else if (windowWidth < 1024) return 3;
        else return 4;
    };

    const setWindowWidth = () => { windowWidth = window.innerWidth; numCols = setNumCols(); };

    onMount(() => {
        windowWidth = window.innerWidth; numCols = setNumCols();	
        window.addEventListener('resize', setWindowWidth);

        return () => { 
            window.removeEventListener('resize', setWindowWidth);  
        }
    });
    // -------------------------------------------------------------------------------------------------



    // -------------------------------------------------------------------------------------------------
    // Prevent the user from leaving the page
    // -------------------------------------------------------------------------------------------------
    function beforeunload(event: BeforeUnloadEvent) {
        if ((AppC.currentState !== AppStates.QRCODE) && (AppC.currentState !== AppStates.QRSEARCH))
        {
            event.preventDefault();
            return (event.returnValue = "");
        }
    }
    // -------------------------------------------------------------------------------------------------



    // -------------------------------------------------------------------------------------------------
    // UI Controlling Variables
    // -------------------------------------------------------------------------------------------------
    let inducted : boolean = false;
    let list : boolean = true;
    let availability : boolean = false;
    let loggedIn : boolean = false;
    let searchString : string;
    let opened : boolean;
    let appState : AppStates;
    let qrcode : boolean = false;

    let queryVars : QueryVars = { 
        name : "", 
        qrcode : "",
        search : "", 
        qrsearch : ""
    };

    let appVars : AppVars = {
        session : null,
        message : "",
        item : null
    }
    // -------------------------------------------------------------------------------------------------



    // -------------------------------------------------------------------------------------------------
    // GraphQL
    // -------------------------------------------------------------------------------------------------
    // GraphQL client setup 
    const client = new ApolloClient({
        uri:  '/api',
        cache: new InMemoryCache()
    });
    setClient(client);
    // -------------------------------------------------------------------------------------------------



    // -------------------------------------------------------------------------------------------------
    // The main UX / App App Controller
    // -------------------------------------------------------------------------------------------------
    let createAppKey = (currentState : AppStates, triggerEvent : AppEvents) => currentState + '|' + triggerEvent;
    let AppC = new Automation<AppStates, AppEvents> (AppStates.LOAD, createAppKey, AppStates._);

    // -------------------------------------------------------------------------------------------------
    // Transitions
    // -------------------------------------------------------------------------------------------------
    // Check and load the query strings as these define which page to then show
    AppC.add_transition(AppStates.LOAD,                     AppEvents.LOAD_QUERY_STRINGS,       AppStates.INIT,                         loadQueryStrings);

    // Initialisation and choosing which page to show based on the query strings
    AppC.add_transition(AppStates.INIT,                     AppEvents.SHOW_QRCODE,              AppStates.QRCODE,                       doNothing);
    AppC.add_transition(AppStates.INIT,                     AppEvents.SHOW_QRSEARCH,            AppStates.QRSEARCH,                     doNothing);
    AppC.add_transition(AppStates.INIT,                     AppEvents.SHOW_BOOKING,             AppStates.MAIN_BOOKING,                 doNothing);
    AppC.add_transition(AppStates.INIT,                     AppEvents.SHOW_LIST,                AppStates.MAIN_LIST,                    doNothing);

    AppC.add_transition(AppStates.MAIN_LIST,                AppEvents.SHOW_BOOKING,             AppStates.MAIN_BOOKING,                 setItem);
    AppC.add_transition(AppStates.MAIN_BOOKING,             AppEvents.SHOW_LIST,                AppStates.MAIN_LIST,                    doNothing);
    AppC.add_transition(AppStates.MAIN_BOOKING,             AppEvents.SHOW_DETAILS,             AppStates.MAIN_DETAILS,                 setItem);
    AppC.add_transition(AppStates.MAIN_DETAILS,             AppEvents.SHOW_BOOKING,             AppStates.MAIN_BOOKING,                 doNothing);

    AppC.add_transition(AppStates.MAIN_LIST,                AppEvents.SHOW_DETAILS,             AppStates.ITEM_DETAILS,                 setItem);
    AppC.add_transition(AppStates.ITEM_DETAILS,             AppEvents.SHOW_LIST,                AppStates.MAIN_LIST,                    doNothing);

    // -------------------------------------------------------------------------------------------------
    // Actions
    // -------------------------------------------------------------------------------------------------

    // Load the values from the query strings
    function loadQueryStrings (_ : {}) {
        queryVars.name = getQueryStringVal("item");
        queryVars.qrcode = getQueryStringVal("qrcode");
        queryVars.search = getQueryStringVal("search");
        searchString = queryVars.search?queryVars.search:"";
        queryVars.qrsearch = getQueryStringVal("qrsearch");

        if (queryVars.qrcode) {
            if (queryVars.qrcode === "all") {
                qrcode = true;
                queryVars.qrcode = "";
                AppC.step(AppEvents.SHOW_LIST);
            } else {
                AppC.step(AppEvents.SHOW_QRCODE);
            }
        }
        else if (queryVars.qrsearch) AppC.step(AppEvents.SHOW_QRSEARCH);
        else {
            if (queryVars.name) AppC.step(AppEvents.SHOW_BOOKING);
            else AppC.step(AppEvents.SHOW_LIST);
        };
        updateUI;     
    }

    // Do (almost) nothing
    function doNothing (_ : {} = {}) { updateUI(); }

    // Force the UI to update (and update a few variables)
    function updateUI (_ : {} = {}) { 
        if (!opened) {
            if (LoginC.currentState === LoginStates.LOGIN_DIALOG_OPEN) {
                behavior("Login_dialog", "show");
                opened = true;
            }
        }
        else {
            opened = false;
        }

        appVars.message = (
            (LoginC.currentState === LoginStates.LOGGED_IN) ?
                (
                    (appVars.item) ? 
                        "Use the calendar to make a booking or edit existing bookings."
                    :
                        "Choose an item to see or edit bookings"
                )
            :
                "This is still under heavy development, so for now, this is only test data.  \
                Please try this out and send comments to roy.davies@auckland.ac.nz.  Log in to create and edit bookings."
        );
        loggedIn = (LoginC.currentState === LoginStates.LOGGED_IN);
        appState = AppC.currentState;
        appVars = appVars;
    };


    function setItem(item : ItemT) {
        appVars.item = item;
        updateUI();
    }
    // -------------------------------------------------------------------------------------------------



    // -------------------------------------------------------------------------------------------------
    // The login dialog box Controller
    // -------------------------------------------------------------------------------------------------
    let createLoginKey = (currentState : LoginStates, triggerEvent : LoginEvents) => currentState + '|' + triggerEvent;
    let LoginC = new Automation<LoginStates, LoginEvents> (LoginStates.LOAD, createLoginKey, LoginStates._);

    // -------------------------------------------------------------------------------------------------
    // Transitions
    // -------------------------------------------------------------------------------------------------
    LoginC.add_transition(LoginStates.LOAD,                 LoginEvents.INITIALISE,             LoginStates.LOGIN_DIALOG_CLOSED,        initialise);
    LoginC.add_transition(LoginStates._,                    LoginEvents.OPEN_DIALOG,            LoginStates.LOGIN_DIALOG_OPEN,          updateUI);
    LoginC.add_transition(LoginStates._,                    LoginEvents.CLOSE_DIALOG,           LoginStates.LOGIN_DIALOG_CLOSED,        updateUI);
    LoginC.add_transition(LoginStates._,                    LoginEvents.LOG_OUT,                LoginStates.LOGGED_OUT,                 resetLoginVariables);
    LoginC.add_transition(LoginStates.LOGIN_DIALOG_OPEN,    LoginEvents.LOG_IN,                 LoginStates.LOGGED_IN,                  setSession);

    // -------------------------------------------------------------------------------------------------
    // Actions
    // -------------------------------------------------------------------------------------------------
    // Set up variables
    function initialise(_:{}={}) {
        appVars.session = null; appVars.item = null;
        updateUI();
    }
    function resetLoginVariables(_:{}={}) {
        appVars.session = null;
        updateUI();
    }
    function setSession( session : Session ) {
        appVars.session = session;
        updateUI();
    }
    // -------------------------------------------------------------------------------------------------


    // -------------------------------------------------------------------------------------------------
    // Start with the first event
    // -------------------------------------------------------------------------------------------------
    AppC.step(AppEvents.LOAD_QUERY_STRINGS);
    LoginC.step(LoginEvents.INITIALISE);
    // -------------------------------------------------------------------------------------------------


    // -------------------------------------------------------------------------------------------------
    // Log in or out
    // -------------------------------------------------------------------------------------------------
    function login (event : any) {
        switch (event.detail.message)
        {
            case 'close' : LoginC.step(LoginEvents.CLOSE_DIALOG); break;
            case 'success' : LoginC.step(LoginEvents.LOG_IN, event.detail.data); break;
            default: break;
        }
    }
    // -------------------------------------------------------------------------------------------------

</script>
<!----------------------------------------------------------------------------------------------------->



<!------------------------------------------------------------------------------------------------------
Styles
------------------------------------------------------------------------------------------------------->
<style>

</style>
<!----------------------------------------------------------------------------------------------------->



<!------------------------------------------------------------------------------------------------------
Layout
------------------------------------------------------------------------------------------------------->
<svelte:window on:beforeunload={beforeunload} />
<main>

    <Login id="Login_dialog" on:login={login}/>

    {#if (AppC.currentState === AppStates.QRCODE)}
        <QRcode {queryVars}/>
    {:else if (AppC.currentState === AppStates.QRSEARCH)}
        <QRcode {queryVars}/>
    {:else if (AppC.currentState === AppStates.ITEM_DETAILS) || (AppC.currentState === AppStates.MAIN_DETAILS)}
        Details
    {:else if (AppC.currentState === AppStates.MAIN_BOOKING)}
        <TopBar bind:numCols bind:loggedIn bind:LoginC bind:list bind:availability bind:inducted bind:searchString bind:AppC/>
        <Booking {appVars} {queryVars} {loggedIn}/>
    {:else}
        <TopBar bind:numCols bind:loggedIn bind:LoginC bind:list bind:availability bind:inducted bind:searchString bind:AppC/>

        <Content style={numCols>2?"padding-top: 80px;":"padding-top: 60px;"}>
            <Message ui yellow>
                <Grid ui stackable>
                    <Column four wide>
                        <Image ui _={numCols<=2?"small":""} src="/images/logo.png"/>
                    </Column>
                    <Column twelve wide>
                        {#if loggedIn && appVars.session}
                            <Header>Welcome {appVars.session.person.name} ({appVars.session.person.upi})</Header>
                            {appVars.message}
                        {:else}
                            <Header>Welcome to the SDL / TTL Booking System.</Header>
                            {appVars.message}
                        {/if}
                    </Column>
                </Grid>
            </Message>
        
            <Items_Loader {queryVars} {numCols} {searchString} {loggedIn} upi={appVars.session?appVars.session.person.upi:""} {inducted} {availability} {qrcode} {list}/>
        </Content>
    {/if}

</main>
<!----------------------------------------------------------------------------------------------------->