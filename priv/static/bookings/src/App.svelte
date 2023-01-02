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

    // -------------------------------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------------------------------
    let loginDialogOpen : boolean = false;
    let searchValue : string = "";
    let inducted : boolean = false;
    let availability : boolean = true;
    let upi : string = "";
    let sessionid : string = "";
    let loggedIn : boolean = false;
    let name : string = "";
    let qrcode : string = "";
    let qrsearch : string = "";
    let itemName : string = "";
    let message : string = "";
    let link : string = "";

    // -------------------------------------------------------------------------------------------------
    // Query strings
    // -------------------------------------------------------------------------------------------------
    itemName = getQueryStringVal("item");
    qrcode = getQueryStringVal("qrcode");
    searchValue = getQueryStringVal("search");
    qrsearch = getQueryStringVal("qrsearch");

    $: search = searchValue?searchValue:"";
    $: message = (itemName && loggedIn) ? "Use the calendar to make a booking or edit existing bookings." : ((loggedIn) ? "Choose an item to see or edit bookings" : "Log in to see and edit bookings.")

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
    const cancelBooking = () => {itemName = "";}

    // Use the item chosen to go to the booking calendar
    const bookItem = (item: Item) => { itemName = item.name; }

    // Use the item chosen to go to the booking calendar
    const showItem = (url: string) => { link = url; }//window.open (url, '_blank'); }

    // Done showing the details for an item
    const doneDetails = () => { link = ""; }

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
      {#if qrsearch}
        <QRcode {qrsearch}/>
      {:else if qrcode}
        <QRcode itemName={qrcode}/>
      {:else}
        <Navbar {message} context={link?"details":(itemName?"booking":"main")} {name} {itemName} {search} {doLoginOrLogout} {loggedIn} {changeVar} {doneDetails} {cancelBooking} {availability} {inducted}/>
        <Modal size="sm" opened={loginDialogOpen} on:close={closeLoginDialog} title="Log In" centered >
          <Login {closeLoginDialog} {successfulLogin} />
        </Modal>
        {#if link}
          <Details {link} />
        {:else if itemName}
          <Booking {sessionid} {itemName} {upi} {loggedIn}/>
        {:else}
          <Items {bookItem} {search} {inducted} {availability} {upi} {loggedIn} {showItem}/>
        {/if}
      {/if}
    </SvelteUIProvider>
  </main>
<!----------------------------------------------------------------------------------------------------->