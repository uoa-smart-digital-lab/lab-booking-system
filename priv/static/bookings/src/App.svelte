<script lang="ts">
    import { ApolloClient, InMemoryCache } from '@apollo/client';
    import { setClient } from 'svelte-apollo';

    import type { QueryVars, AppVars } from './lib/Types.svelte';
    import { AppStates, AppEvents, LoginStates, LoginEvents } from './lib/Types.svelte';
    import Automation from './lib/FiniteStateMachine';

    import { behavior, Button, Buttons, Icon, Segment, Input, Menu, Item, Checkbox } from "svelte-fomantic-ui";

    import Login from "./lib/Login.svelte";
    import Items_Loader from "./lib/Items_Loader.svelte";
    import { Itemtype, Usertype } from "./lib/Graphql.svelte";
    import type { Item as ItemT, Session } from './lib/Graphql.svelte';
    import { getQueryStringVal } from './lib/Querystring.svelte';

    // UI Controlling Variales
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
        session : {
            sessionid : "",
            person : {
                upi : "",
                name : "",
                status : Usertype.USER,
                details : {},
                tokens : 0,
                bookings : [],
                inductions : []
            }
        },
        message : "",
        item : null
    }


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



    // -------------------------------------------------------------------------------------------------
    // Actions
    // -------------------------------------------------------------------------------------------------

    // Load the values from the query strings
    function loadQueryStrings (_ : {}) {
        queryVars.name = getQueryStringVal("item");
        queryVars.qrcode = getQueryStringVal("qrcode");
        queryVars.search = getQueryStringVal("search");
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
        // opened = (LoginC.currentState === LoginStates.LOGIN_DIALOG_OPEN);
        // appVars.message = (
        //     (LoginC.currentState === LoginStates.LOGGED_IN) ?
        //         (
        //             (appVars.item) ? 
        //                 "Use the calendar to make a booking or edit existing bookings."
        //             :
        //                 "Choose an item to see or edit bookings"
        //         )
        //     :
        //         "Welcome to the SDL / TTL Booking System.  This is still under heavy development, so for now, this is only test data.  \
        //         Please try this out and send comments to roy.davies@auckland.ac.nz.  Log in to create and edit bookings."
        // );
        // loggedIn = (LoginC.currentState === LoginStates.LOGGED_IN);
        appState = AppC.currentState;
        appVars = appVars;
    };


    function setItem(item : ItemT) {
        appVars.item = item;
        updateUI();
    }
    // -------------------------------------------------------------------------------------------------



    // -------------------------------------------------------------------------------------------------
    // Start with the first event
    // -------------------------------------------------------------------------------------------------
    AppC.step(AppEvents.LOAD_QUERY_STRINGS);
    // LoginC.step(LoginEvents.INITIALISE);
    // -------------------------------------------------------------------------------------------------


</script>

<main>
    <Login id="Login_dialog"/>

    <Menu ui top stackable attached compact>
        <Item>
            <Button ui fluid on:click={()=>{behavior("Login_dialog", "show")}}>
                <Icon user/>
                Login
            </Button>
        </Item>

        <Menu right compact>
            <Item>
                <Buttons ui>
                    <Button ui icon _={list?"green":"grey"} on:click={()=>list=true}>
                        <Icon list/>
                    </Button>
                    <Button ui icon _={!list?"green":"grey"} on:click={()=>list=false}>
                        <Icon th/>
                    </Button>
                </Buttons>
            </Item>
            <Item>
                <Checkbox ui right aligned toggle fluid label="Bookable" bind:checked={availability}/>
            </Item>
            <Item>
                <Checkbox ui right aligned toggle fluid label="Inducted for" bind:checked={inducted}/>
            </Item>
            <Item ui right aligned category search>
                <Input ui>
                    <Input text bind:value={searchString} placeholder="Search..."/>
                </Input>
            </Item>
        </Menu>
    </Menu>

    <Segment ui basic>
        <Items_Loader {searchString} {loggedIn} upi={appVars.session.person.upi} {inducted} {availability} {qrcode} {list}/>
    </Segment>
</main>

<style>

</style>
