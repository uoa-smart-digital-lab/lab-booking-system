<!------------------------------------------------------------------------------------------------------
The main App
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import { ApolloClient, InMemoryCache } from '@apollo/client';
    import { setClient } from 'svelte-apollo';
    import Items from './lib/Items.svelte';
    import Navbar from './lib/Navbar.svelte';
    import Login from './lib/Login.svelte';
    import QRcode from './lib/QRcode.svelte';
    import Booking from './lib/Booking.svelte';
    import Details from './lib/Details.svelte';
    import { SvelteUIProvider, Divider, Modal } from '@svelteuidev/core';
    import { getQueryStringVal } from './lib/Querystring.svelte';
    import type { Item, Session } from './lib/Graphql.svelte';
    import Automation from './lib/FiniteStateMachine';
    import type { QueryVars, AppVars } from './lib/Types.svelte';
    import { AppStates, AppEvents, LoginStates, LoginEvents } from './lib/Types.svelte';
    import { Person } from 'radix-icons-svelte';

    // -------------------------------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------------------------------
    let inducted : boolean = false;
    let availability : boolean = false;
    let loggedIn : boolean = false;
    let name : string = "";
    let sessionid : string = "";
    let itemName : string = "";
    let link : string = "";
    let upi : string = "";
    let theItem : Item;

    let opened : boolean;

    let queryVars : QueryVars = { 
        item : "", 
        qrcode : "",
        search : "", 
        qrsearch : ""
    };

    let appVars : AppVars = {
        session : null,
        message : "",
        item : null
    }

    let updater : number = 0;

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
    AppC.add_transition(AppStates.INIT,                     AppEvents.SHOW_QRCODE,              AppStates.QRCODE,                       DoNothing);
    AppC.add_transition(AppStates.INIT,                     AppEvents.SHOW_QRSEARCH,            AppStates.QRSEARCH,                     DoNothing);
    AppC.add_transition(AppStates.INIT,                     AppEvents.SHOW_MAIN_DETAILS,        AppStates.MAIN_DETAILS,                 DoNothing);
    AppC.add_transition(AppStates.INIT,                     AppEvents.SHOW_MAIN_BOOKING,        AppStates.MAIN_BOOKING,                 DoNothing);
    AppC.add_transition(AppStates.INIT,                     AppEvents.SHOW_MAIN_LIST,           AppStates.MAIN_LIST,                    DoNothing);

    // -------------------------------------------------------------------------------------------------
    // Actions
    // -------------------------------------------------------------------------------------------------

    // Load the values from the query strings
    function loadQueryStrings (_ : {}) {
        queryVars.item = getQueryStringVal("item");
        queryVars.qrcode = getQueryStringVal("qrcode");
        queryVars.search = getQueryStringVal("search");
        queryVars.qrsearch = getQueryStringVal("qrsearch");

        if (queryVars.qrcode) AppC.step(AppEvents.SHOW_QRCODE);
        else if (queryVars.qrsearch) AppC.step(AppEvents.SHOW_QRSEARCH);
        else {
            if (link) AppC.step(AppEvents.SHOW_MAIN_DETAILS);
            else if (queryVars.item) AppC.step(AppEvents.SHOW_MAIN_BOOKING);
            else AppC.step(AppEvents.SHOW_MAIN_LIST);
        }        
    }

    // Do nothing
    function DoNothing (_ : {} = {}) { }
    // Force the UI to update (and update a few variables)
    function updateUI (_ : {} = {}) { 
        opened = (LoginC.currentState === LoginStates.LOGIN_DIALOG_OPEN);
        appVars.message = (
            (LoginC.currentState === LoginStates.LOGGED_IN) ?
                (
                    (itemName) ? 
                        "Use the calendar to make a booking or edit existing bookings."
                    :
                        "Choose an item to see or edit bookings"
                )
            :
                "Log in to create and edit bookings."
        );
        loggedIn = appVars.session ? true : false;
    };
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
    LoginC.add_transition(LoginStates.LOGIN_DIALOG_OPEN,    LoginEvents.LOG_IN,                 LoginStates.LOGGED_IN,                  updateUI);

    // -------------------------------------------------------------------------------------------------
    // Actions
    // -------------------------------------------------------------------------------------------------
    // Set up variables
    function initialise(_:{}={}) {
        appVars.session = null; appVars.message = ""; appVars.item = null;
        opened = false;
    }
    // After logging in successfully, use the Session to set up various parameters
    function successfulLogin(session : Session) {
        appVars.session = session;
        LoginC.step(LoginEvents.LOG_IN);
        updateUI();
    }
    function resetLoginVariables(_:{}={}) {
        appVars.session = null;
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
    // Some Reactive elemnts
    // -------------------------------------------------------------------------------------------------
    $: search = queryVars.search?queryVars.search:"";
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



    // Log in or out
    const doLoginOrLogout = () => {
        if (LoginC.currentState === LoginStates.LOGGED_IN) {
            LoginC.step(LoginEvents.LOG_OUT);
        }
        else {
            LoginC.step(LoginEvents.OPEN_DIALOG);
        }
    }

    // Close the login dialog box like with the cancel button
    const closeLoginDialog = () => { LoginC.step(LoginEvents.CLOSE_DIALOG); }

    // Cancel the booking calendar view and come back to the list
    const cancelBooking = () => {itemName = ""; link = ""; theItem = null;}

    // Use the item chosen to go to the booking calendar
    const bookItem = (item: Item) => { window.scrollTo(0,0); itemName = item.name; }

    // Use the item chosen to go to the booking calendar
    const showItem = (url: string) => { window.scrollTo(0,0); link = url; }//window.open (url, '_blank'); }

    const setItem = (item: Item) => {console.log(item); theItem = item; }

    // Done showing the details for an item
    const doneDetails = () => { 
      link = "";
    }

    // Given a variable name, change the corresponding variable (this is clunky - there has to be a better way)
    const changeVar = (name: string, newvalue: any) => {
        switch (name) {
            case "search" : queryVars.search = newvalue; break;
            case "availability" : availability = newvalue; break;
            case "inducted" : inducted = newvalue; break;
            default: break;
        }
    }
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
  <main>
      <SvelteUIProvider themeObserver="light" fluid>
          {#if (AppC.currentState === AppStates.QRSEARCH)}
              <QRcode {queryVars}/>
          {:else if (AppC.currentState === AppStates.QRCODE)}
              <QRcode {queryVars}/>
          {:else}

              <Navbar {updater} {queryVars} {appVars} appState={AppC.currentState} loginState={LoginC.currentState} {showItem} {doneDetails} {doLoginOrLogout} {changeVar} {cancelBooking}/>

              <Modal size="sm" {opened} on:close={closeLoginDialog} title="Log In" centered >
                  <Login {closeLoginDialog} {successfulLogin} />
              </Modal>

              {#if      (AppC.currentState === AppStates.MAIN_DETAILS)}
                  <Details {link} />
              {:else if (AppC.currentState === AppStates.MAIN_BOOKING)}
                  <Booking {sessionid} {itemName} {setItem} {upi} {loggedIn}/>
              {:else}
                  <Items {bookItem} {search} {inducted} {availability} {upi} {loggedIn} {showItem}/>
              {/if}
          {/if}
      </SvelteUIProvider>
  </main>
<!----------------------------------------------------------------------------------------------------->