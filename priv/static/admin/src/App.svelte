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
  import { CounterClockwiseClock, Person } from 'radix-icons-svelte';

  // -------------------------------------------------------------------------------------------------
  // Variables
  // -------------------------------------------------------------------------------------------------

  // UI Controlling Variales
  let inducted : boolean = false;
  let list : boolean = true;
  let availability : boolean = false;
  let loggedIn : boolean = true;
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
      opened = (LoginC.currentState === LoginStates.LOGIN_DIALOG_OPEN);
      appVars.message = (
          (LoginC.currentState === LoginStates.LOGGED_IN) ?
              (
                  (appVars.item) ? 
                      "Use the calendar to make a booking or edit existing bookings."
                  :
                      "Choose an item to see or edit bookings"
              )
          :
              "Welcome to the SDL / TTL Booking System.  This is still under heavy development, so for now, this is only test data.  \
              Please try this out and send comments to roy.davies@auckland.ac.nz.  Log in to create and edit bookings."
      );
      loggedIn = (LoginC.currentState === LoginStates.LOGGED_IN);
      appState = AppC.currentState;
      appVars = appVars;
  };


  function setItem(item : Item) {
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
  // Some Reactive elemnts
  // -------------------------------------------------------------------------------------------------
  // $: queryVars.search = searchString;
  // $: loggedIn = (LoginC.currentState === LoginStates.LOGGED_IN);
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
  function login (event : any) {
      switch (event.detail.message)
      {
          case 'login' : LoginC.step(LoginEvents.OPEN_DIALOG); break;
          case 'close' : LoginC.step(LoginEvents.CLOSE_DIALOG); break;
          case 'logout' : LoginC.step(LoginEvents.LOG_OUT); break;
          case 'success' : LoginC.step(LoginEvents.LOG_IN, event.detail.data); break;
          default: break;
      }
  }
  // Clost the login dialog box
  function closeLogin () { login ( { detail : { message : 'close', data : {} } } ) }

  // Cancel the booking calendar view and come back to the list
  function doneBooking (_event: any) {
      appVars.item = null;
      AppC.step(AppEvents.SHOW_LIST);
  }

  // Use the item chosen to go to the booking calendar
  function bookItem (event: any) { 
      window.scrollTo(0,0);
      AppC.step(AppEvents.SHOW_BOOKING, event.detail.item);
  }

  function setTheItem (event: any) {
      appVars.item = event.detail.item;
      updateUI();
  }

  // Done showing the details for an item
  function showDetails ( event: any ) {
      window.scrollTo(0,0);
      AppC.step(AppEvents.SHOW_DETAILS, event.detail.item);
  }

  function doneDetails ( _event : any ) {
      if (AppC.currentState === AppStates.MAIN_DETAILS)
      {
          AppC.step(AppEvents.SHOW_BOOKING);
      }
      else
      {
          AppC.step(AppEvents.SHOW_LIST);
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
<!-- <svelte:window on:popstate={()=>{alert("HERE")}}/> -->
  
<main>
  <SvelteUIProvider themeObserver="light" fluid>
      {#if ((appState === AppStates.QRSEARCH) || (appState === AppStates.QRCODE))}
          <QRcode {queryVars}/>
      {:else}

          <Navbar 
              bind:searchString={searchString}
              bind:availability={availability}
              bind:inducted={inducted}
              bind:list={list}
              on:login={login}
              on:doneBooking={doneBooking}
              on:showDetails={showDetails}
              on:doneDetails={doneDetails}
              {queryVars} {appVars} {appState} {loggedIn} />

          <Modal size="sm" {opened} on:close={closeLogin} title="Log In" centered >
              <Login on:login={login} />
          </Modal>

          {#if (appState === AppStates.MAIN_DETAILS) || (appState === AppStates.ITEM_DETAILS)}
              <Details {appVars} />
          {:else if (appState === AppStates.MAIN_BOOKING)}
              <Booking on:setItem={setTheItem} {queryVars} {appVars} {loggedIn}/>
          {:else}
              <Items {list} {qrcode} on:book={bookItem} on:showDetails={showDetails} {searchString} {inducted} {availability} upi={appVars.session?appVars.session.person.upi:""} {loggedIn}  />
          {/if}
      {/if}
  </SvelteUIProvider>
</main>
<!----------------------------------------------------------------------------------------------------->