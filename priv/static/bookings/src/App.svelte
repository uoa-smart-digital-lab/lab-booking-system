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
    import type { QueryVars } from './lib/Types.svelte';
    import Automation from './lib/FiniteStateMachine';
    // import Item from './lib/Item.svelte';

    // -------------------------------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------------------------------
    let loginDialogOpen : boolean = false;
    let searchValue : string = "";
    let inducted : boolean = false;
    let availability : boolean = false;
    let upi : string = "";
    let sessionid : string = "";
    let loggedIn : boolean = false;
    let name : string = "";
    let qrcode : string = "";
    let qrsearch : string = "";
    let itemName : string = "";
    let message : string = "";
    let link : string = "";
    let theItem : Item;

    let queryVars : QueryVars;

    enum pages { QRSEARCH = "qrsearch", QRCODE = "qrcode", MAIN_DETAILS = "main_details", MAIN_BOOKING = "main_booking", MAIN_LIST = "main_list" };
    let tick : number = 0;
    let page : pages = pages.MAIN_LIST;

    enum states { _ = "_", LOAD = "load", INIT = "init", VIEW = "view" };
    enum events { LOAD_QUERY_STRINGS = "load_query_strings", SET_PAGE = "set_page"}

    // -------------------------------------------------------------------------------------------------
    // Controller Functions
    // -------------------------------------------------------------------------------------------------
    // Load the initial query strings
    const loadQueryStrings = ( _ : {} ) => {
        queryVars.itemName = getQueryStringVal("item");
        queryVars.qrcode = getQueryStringVal("qrcode");
        queryVars.searchValue = getQueryStringVal("search");
        queryVars.qrsearch = getQueryStringVal("qrsearch");

        Controller.step(events.SET_PAGE, {});
    }

    // Based on the query strings, set which page to show
    const setPage = ( _ : {} ) => {
        if (queryVars.qrsearch) {
            page = pages.QRSEARCH;
        }
        else if (queryVars.qrcode) {
            page = pages.QRCODE;
        }
        else {
          if (link) {
              page = pages.MAIN_DETAILS;
          }
          else if (queryVars.itemName) {
              page = pages.MAIN_BOOKING;
          }
          else {
              page = pages.MAIN_LIST;
          }
        }
    }

    // Do nothing (just refresh the page)
    function doNothing (_args : {}) { tick ++; };


    // -------------------------------------------------------------------------------------------------
    // Create the main UX / App Controller
    // -------------------------------------------------------------------------------------------------
    let createKey = (currentState : states, triggerEvent : events) => currentState + '|' + triggerEvent;
    let Controller = new Automation<states, events> (states.LOAD, createKey, states._);


    // -------------------------------------------------------------------------------------------------
    // Create the Transitions
    // -------------------------------------------------------------------------------------------------
    Controller.add_transition(states.LOAD,      events.LOAD_QUERY_STRINGS,      states.INIT,            loadQueryStrings);        // Load the query strings
    Controller.add_transition(states.INIT,      events.SET_PAGE,                states.VIEW,            setPage);


    // Start with the first event
    Controller.step(events.LOAD_QUERY_STRINGS, {});
    // -------------------------------------------------------------------------------------------------
    // Query strings
    // -------------------------------------------------------------------------------------------------
    // itemName = getQueryStringVal("item");
    // qrcode = getQueryStringVal("qrcode");
    // searchValue = getQueryStringVal("search");
    // qrsearch = getQueryStringVal("qrsearch");

    $: search = searchValue?searchValue:"";
    $: message = (itemName && loggedIn) ? "Use the calendar to make a booking or edit existing bookings." : ((loggedIn) ? "Choose an item to see or edit bookings" : "Log in to create and edit bookings.")

    // -------------------------------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------------------------------
    // GraphQL client setup 
    const client = new ApolloClient({
      uri:  '/api',
      cache: new InMemoryCache()
    });
    setClient(client);

    // Log in or out
    const doLoginOrLogout = () => {
      if (sessionid === "") {
        loginDialogOpen = true;
      }
      else {
        sessionid = "";
        loggedIn = false;
        name = "";
        itemName = "";
        upi = "";
        inducted = false;
        availability = true;
        loginDialogOpen = false;
      }
    }

    // Close the login dialog box like with the cancel button
    const closeLoginDialog = () => { loginDialogOpen = false; }

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
        case "search" : searchValue = newvalue; break;
        case "availability" : availability = newvalue; break;
        case "inducted" : inducted = newvalue; break;
        default: break;
      }
    }

    // After logging in successfully, use the Session to set up various parameters
    const successfulLogin = (data : Session) => {
      upi = data.person.upi;
      name = data.person.name;
      sessionid = data.sessionid;
      loggedIn = true;
      loginDialogOpen = false;
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
          {#if      (page === pages.QRSEARCH)}
              <QRcode {queryVars}/>
          {:else if (page === pages.QRCODE)}
              <QRcode {queryVars}/>
          {:else}
              <Navbar {message} context={link?"details":(itemName?"booking":"main")} {name} item={theItem} {showItem} {doneDetails} {search} {doLoginOrLogout} {loggedIn} {changeVar} {cancelBooking} {availability} {inducted}/>
              <Modal size="sm" opened={loginDialogOpen} on:close={closeLoginDialog} title="Log In" centered >
                  <Login {closeLoginDialog} {successfulLogin} />
              </Modal>
              {#if      (page === pages.MAIN_DETAILS)}
                  <Details {link} />
              {:else if (page === pages.MAIN_BOOKING)}
                  <Booking {sessionid} {itemName} {setItem} {upi} {loggedIn}/>
              {:else}
                  <Items {bookItem} {search} {inducted} {availability} {upi} {loggedIn} {showItem}/>
              {/if}
          {/if}
      </SvelteUIProvider>
  </main>
<!----------------------------------------------------------------------------------------------------->