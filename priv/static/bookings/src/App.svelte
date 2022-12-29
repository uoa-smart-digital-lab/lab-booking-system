<!------------------------------------------------------------------------------------------------------
The main App
------------------------------------------------------------------------------------------------------->
<script>
  // @ts-nocheck

    import { ApolloClient, InMemoryCache } from '@apollo/client';
    import { setClient } from 'svelte-apollo';
    import Items from './lib/Items.svelte';
    import Navbar from './lib/Navbar.svelte';
    import Login from './lib/Login.svelte';
    import QRcode from './lib/QRcode.svelte';
    import Booking from './lib/Booking.svelte';
    import { SvelteUIProvider, Divider, Modal } from '@svelteuidev/core';
    import { getQueryStringVal } from './lib/Querystring.svelte';

    let logindialogopen = false;
    let loading = true;
    let searchvalue = "";
    let inducted = false;
    let availability = true;
    let daybookingvalue = true;
    let upi = "";
    let sessionid = "";
    let loggedin = false;
    let name = "";
    let qrcode = "";
    let qrsearch = "";
    let itemname = "";

    itemname = getQueryStringVal("item");
    qrcode = getQueryStringVal("qrcode");
    searchvalue = getQueryStringVal("search");
    qrsearch = getQueryStringVal("qrsearch");

    $: search = searchvalue;
    $: daybooking = daybookingvalue;

    const client = new ApolloClient({
      uri:  '/api',
      cache: new InMemoryCache()
    });
    setClient(client);

    const doneloading = () => { loading = false; return (""); }
    const dologin = () => {
      if (sessionid === "") {
        logindialogopen = true;
      }
      else {
        sessionid = "";
        loggedin = false;
        name = "";
        itemname = "";
        upi = "";
        inducted = false;
        availability = true;
        logindialogopen = false;
      }
    }
    const closelogindialog = () => { logindialogopen = false; }
    const cancelbooking = () => {itemname = "";}

    const bookitem = (theItem) => { itemname = theItem.name; }

    const changevar = (name, newvalue) => {
      switch (name) {
        case "search" : searchvalue = newvalue; break;
        case "availability" : availability = newvalue; break;
        case "inducted" : inducted = newvalue; break;
        case "daybooking" : daybookingvalue = newvalue; break;
        default: break;
      }
    }

    const successfullogin = (data) => {
      upi = data.person.upi;
      name = data.person.name;
      sessionid = data.sessionid;
      loggedin = true;
      logindialogopen = false;
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
        <QRcode itemname={qrcode}/>
      {:else}
        <Navbar context={itemname?"booking":"main"} {name} {itemname} {search} {dologin} {loggedin} {changevar} {cancelbooking} {availability} {inducted} {daybooking}/>
        {#if itemname}
          <Booking {itemname} {daybooking} />
        {:else}
          {#if !loading}
            <Modal opened={logindialogopen} on:close={closelogindialog} title="Log In" centered>
              <Login {closelogindialog} {successfullogin} />
            </Modal>
          {/if}
          <Items {doneloading} {bookitem} {search} {inducted} {availability} {upi} {loggedin}/>
        {/if}
      {/if}
    </SvelteUIProvider>
  </main>
<!----------------------------------------------------------------------------------------------------->